import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_interpreter/src/resolver_error.dart';

import 'interpreter.dart';

// TODO:
// - Unlink resolver and interpreter and make the resolver(analyzer?) its own
//   package (The text editor doesn't need the interpreter, but it needs the
//   resolver).
// - Warn user for:
//   - Dead code after return statement.
//   - Unused local variable.

enum _FunctionType {
  none,
  function,
  method,
  initializer,
}

enum _ClassType {
  none,

  /// Inside a class that doesn't have a super class.
  ntmClass,

  /// Inside a class that has a super class.
  subClass,
}

/// A resolver.
class Resolver implements ExpressionVisitor<void>, StatementVisitor<void> {
  /// A resolver.
  Resolver(this.interpreter);

  /// The interpreter
  // TODO: Unlink the resolver and the interpreter.
  final Interpreter interpreter;

  /// Lexical scopes nest in both the interpreter and the resolver. They behave
  /// like a stack.
  ///
  /// Keeps track of the stack of scopes currently, uh, in scope. Each element
  /// in the stack is a Map representing a single block scope. Keys, as in
  /// Environment, are variable names.
  ///
  /// The scope stack is only used for local block scopes. Variables declared at
  /// the top level in the global scope are not tracked by the resolver since
  /// they are more dynamic in Ntm. When resolving a variable, if we can’t find
  /// it in the stack of local scopes, we assume it must be global.
  ///
  /// The value associated with a key in the scope map represents whether or not
  /// we have finished resolving that variable’s initializer.
  final List<Map<String, bool>> _scopes = [];

  final List<ResolverError> _errors = [];

  var _currentFunction = _FunctionType.none;
  var _currentClass = _ClassType.none;

  void _clear() {
    _scopes.clear();
    _errors.clear;
    _currentFunction = _FunctionType.none;
  }

  List<ResolverError> resolve(Iterable<Statement> statements) {
    _clear();
    _resolveStatements(statements);
    return _errors;
  }

  /// Walks a list of statements and resolves each one.
  void _resolveStatements(Iterable<Statement> statements) {
    for (final statement in statements) {
      _resolveStatement(statement);
    }
  }

  /// Similar to `Interpreter.execute`.
  void _resolveStatement(Statement statement) {
    statement.accept(this);
  }

  /// Similar to `Interpreter.evaluate`.
  void _resolveExpression(Expression expression) {
    expression.accept(this);
  }

  void _beginScope() {
    _scopes.add({});
  }

  void _endScope() {
    _scopes.removeLast();
  }

  /// Declaration adds the variable to the innermost scope so that it shadows
  /// any outer one and so that we know the variable exists. We mark it as “not
  /// ready yet” by binding its name to `false` in the scope map. The value
  /// associated with a key in the scope map represents whether or not we have
  /// finished resolving that variable’s initializer.
  void _declare(Token name) {
    if (_scopes.isEmpty) return;
    final scope = _scopes.last;
    if (scope.containsKey(name.lexeme)) {
      _errors.add(
        ResolverError(
          token: name,
          message:
              'There is already a variable with the name "${name.lexeme}" in this scope.',
        ),
      );
    }
    scope[name.lexeme] = false;
  }

  /// After declaring the variable, we resolve its initializer expression in
  /// that same scope where the new variable now exists but is unavailable. Once
  /// the initializer expression is done, the variable is ready for prime time.
  /// We do that by defining it.
  ///
  /// We set the variable’s value in the scope map to true to mark it as fully
  /// initialized and available for use.
  void _define(Token name) {
    if (_scopes.isEmpty) return;
    _scopes.last[name.lexeme] = true;
  }

  void _resolveLocal(Expression expression, Token name) {
    for (var i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes[i].containsKey(name.lexeme)) {
        interpreter.resolve(expression, _scopes.length - 1 - i);
        return;
      }
    }
  }

  /// It creates a new scope for the body and then binds variables for each of
  /// the function’s parameters.
  ///
  /// Once that’s ready, it resolves the function body in that scope. This is
  /// different from how the interpreter handles function declarations. At
  /// _runtime_, declaring a function doesn’t do anything with the function’s
  /// body. The body doesn’t get touched until later when the function is
  /// called. In a _static_ analysis, we immediately traverse into the body
  /// right then and there.
  void _resolveFunction(FunctionStatement function, _FunctionType type) {
    final enclosingFunction = _currentFunction;
    _currentFunction = type;
    _beginScope();
    for (final param in function.params) {
      _declare(param);
      _define(param);
    }
    _resolveStatements(function.body);
    _endScope();
    _currentFunction = enclosingFunction;
  }

  /// First, we resolve the expression for the assigned value in case it also
  /// contains references to other variables. Then we use our existing
  /// [_resolveLocal] method to resolve the variable that’s being assigned to.
  @override
  void visitAssignExpression(AssignExpression expression) {
    _resolveExpression(expression.value);
    _resolveLocal(expression, expression.name);
  }

  @override
  void visitBinaryExpression(BinaryExpression expression) {
    _resolveExpression(expression.left);
    _resolveExpression(expression.right);
  }

  @override
  void visitBlockStatement(BlockStatement statement) {
    _beginScope();
    _resolveStatements(statement.statements);
    _endScope();
  }

  @override
  void visitClassStatement(ClassStatement statement) {
    final enclosingClass = _currentClass;
    _currentClass = _ClassType.ntmClass;
    _declare(statement.name);
    _define(statement.name);

    if (statement.superclass != null) {
      if (statement.name.lexeme == statement.superclass!.name.lexeme) {
        _errors.add(ResolverError(
          token: statement.superclass!.name,
          message:
              'Class "${statement.name.lexeme}" cannot inherit from itself.',
        ));
      }
      _currentClass = _ClassType.subClass;
      _resolveExpression(statement.superclass!);

      // If the class declaration has a superclass, then we create a new scope
      // surrounding all of its methods. In that scope, we define the name
      // “super”.
      _beginScope();
      _scopes.last['super'] = true;
    }

    // Before we step in and start resolving the method bodies, we push a new
    // scope and define “this” in it as if it were a variable. Then, when we’re
    // done, we discard that surrounding scope.
    _beginScope();
    _scopes.last['this'] = true;

    // Now, whenever a this expression is encountered (at least inside a method)
    // it will resolve to a “local variable” defined in an implicit scope just
    // outside of the block for the method body.

    for (final method in statement.methods) {
      final _FunctionType declaration;
      if (method.name.lexeme == 'init') {
        declaration = _FunctionType.initializer;
      } else {
        declaration = _FunctionType.method;
      }
      _resolveFunction(method, declaration);
    }

    // Once we’re done resolving the class’s methods, we discard that
    // scope with the name "super".
    if (statement.superclass != null) {
      _endScope();
    }

    _endScope();

    _currentClass = enclosingClass;
  }

  @override
  void visitCallExpression(CallExpression expression) {
    _resolveExpression(expression.callee);
    for (final argument in expression.arguments) {
      _resolveExpression(argument);
    }
  }

  @override
  void visitGetExpression(GetExpression expression) {
    // TODO: Add fields to class.
    _resolveExpression(expression.object);
  }

  @override
  void visitExpressionStatement(ExpressionStatement statement) {
    _resolveExpression(statement.expression);
  }

  /// The name of the function itself is bound in the surrounding scope where
  /// the function is declared. When we step into the function’s body, we also
  /// bind its parameters into that inner function scope.
  ///
  /// Similar to [visitVariableStmt], we declare and define the name of the
  /// function in the current scope. Unlike variables, though, we define the
  /// name eagerly, before resolving the function’s body. This lets a function
  /// recursively refer to itself inside its own body.
  ///
  /// Then we resolve the function’s body.
  @override
  void visitFunctionStatement(FunctionStatement statement) {
    _declare(statement.name);
    _define(statement.name);

    _resolveFunction(statement, _FunctionType.function);
  }

  @override
  void visitGroupingExpression(GroupingExpression expression) {
    _resolveExpression(expression.expression);
  }

  /// An if statement has an expression for its condition and one or two
  /// statements for the branches.
  ///
  /// Here, we see how resolution is different from interpretation. When we
  /// resolve an `if` statement, there is no control flow. We resolve the
  /// condition and _both_ branches. Where a dynamic execution steps only into
  /// the branch that _is_ run, a static analysis is conservative, it analyzes
  /// any branch that _could_ be run. Since either one could be reached at
  /// runtime, we resolve both.
  @override
  void visitIfStatement(IfStatement statement) {
    _resolveExpression(statement.condition);
    _resolveStatement(statement.thenBranch);
    if (statement.elseBranch != null) {
      _resolveStatement(statement.elseBranch!);
    }
  }

  @override
  void visitLiteralExpression(LiteralExpression expression) {
    // A literal expression doesn’t mention any variables and doesn’t contain
    // any sub-expressions so there is no work to do.
  }

  /// Since a static analysis does no control flow or short-circuiting, logical
  /// expressions are exactly the same as other binary operators.
  @override
  void visitLogicalExpression(LogicalExpression expression) {
    _resolveExpression(expression.left);
    _resolveExpression(expression.right);
  }

  @override
  void visitSetExpression(SetExpression expression) {
    // TODO: Add fields to class.
    _resolveExpression(expression.value);
    _resolveExpression(expression.object);
  }

  @override
  void visitSuperExpression(SuperExpression expression) {
    if (_currentClass == _ClassType.none) {
      _errors.add(ResolverError(
        token: expression.keyword,
        message: 'Cannot use "super" outside of a class.',
      ));
    } else if (_currentClass != _ClassType.subClass) {
      _errors.add(ResolverError(
        token: expression.keyword,
        message: 'Cannot use "super" in a class with no superclass.',
      ));
    }
    _resolveLocal(expression, expression.keyword);
  }

  @override
  void visitThisExpression(ThisExpression expression) {
    if (_currentClass == _ClassType.none) {
      _errors.add(ResolverError(
        token: expression.keyword,
        message: 'Cannot use "this" outside a class.',
      ));
    }
    _resolveLocal(expression, expression.keyword);
  }

  @override
  void visitPrintStatement(PrintStatement statement) {
    _resolveExpression(statement.expression);
  }

  @override
  void visitReturnStatement(ReturnStatement statement) {
    if (_currentFunction == _FunctionType.none) {
      _errors.add(ResolverError(
        token: statement.keyword,
        message: 'Cannot return from top-level code.',
      ));
    }
    if (statement.value != null) {
      if (_currentFunction == _FunctionType.initializer) {
        _errors.add(ResolverError(
          token: statement.keyword,
          message: 'Cannot return a value from an initializer.',
        ));
      }
      _resolveExpression(statement.value!);
    }
  }

  @override
  void visitUnaryExpression(UnaryExpression expression) {
    _resolveExpression(expression.right);
  }

  /// Resolving a variable declaration adds a new entry to the current innermost
  /// scope’s map.
  ///
  /// We split binding into two steps, declaring then defining, in order to
  /// handle funny edge cases like this:
  ///
  /// ```ntm
  /// var a = 'outer';
  /// {
  ///   var a = a;
  /// }
  /// ```
  ///
  /// This is likely a user error. We make it a compile error instead of a
  /// runtime one. That way, the user is alerted to the problem before any code
  /// is run.
  ///
  /// As we visit expressions, we need to know if we’re inside the initializer
  /// for some variable. We do that by splitting binding into two steps. The
  /// first is declaring it.
  ///
  /// 1. Declaration adds the variable to the innermost scope so that it shadows
  ///    any outer one and so that we know the variable exists.
  /// 2. After declaring the variable, we resolve its initializer expression in
  ///    that same scope where the new variable now exists but is unavailable.
  @override
  void visitVarStatement(VarStatement statement) {
    _declare(statement.name);
    if (statement.initializer != null) {
      _resolveExpression(statement.initializer!);
    }
    _define(statement.name);
  }

  /// First, we check to see if the variable is being accessed inside its own
  /// initializer. This is where the values in the scope map come into play. If
  /// the variable exists in the current scope but its value is `false`, that
  /// means we have declared it but not yet defined it. We report that error.
  ///
  /// After that check, we actually resolve the variable itself.
  @override
  void visitVariableExpression(VariableExpression expression) {
    if (_scopes.isNotEmpty && _scopes.last[expression.name.lexeme] == false) {
      _errors.add(ResolverError(
        token: expression.name,
        message: 'Cannot read local variable in its own initializer.',
      ));
    }
    _resolveLocal(expression, expression.name);
  }

  /// As in `if` statements, with a `while` statement, we resolve its condition
  /// and resolve the body exactly once.
  @override
  void visitWhileStatement(WhileStatement statement) {
    _resolveExpression(statement.condition);
    _resolveStatement(statement.body);
  }
}

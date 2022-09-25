import 'dart:io';

import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_interpreter/src/environment.dart';
import 'package:ntm_interpreter/src/return_exception.dart';
import 'package:ntm_interpreter/src/runtime_error.dart';

import 'callable.dart';
import 'native_functions.dart';
import 'ntm_class.dart';
import 'ntm_function.dart';
import 'ntm_instance.dart';

/// Unlike expressions, statements produce no values, so the return type of the
/// visit methods is `void`, not [Object?].
class Interpreter
    implements ExpressionVisitor<Object?>, StatementVisitor<void> {
  Interpreter() {
    globals.define('clock', const Clock());
  }

  final errors = <RuntimeError>[];

  final globals = Environment();
  late var _environment = globals;

  /// Associates each syntax tree node with its resolved data.
  final Map<Expression, int> _locals = {};

  @override
  Object? visitBinaryExpression(BinaryExpression expression) {
    final left = _evaluate(expression.left);
    final right = _evaluate(expression.right);
    switch (expression.operator.type) {
      case TokenType.greater:
        _checkNumberOperands(expression.operator, left, right);
        return (left as num) > (right as num);
      case TokenType.greaterEqual:
        _checkNumberOperands(expression.operator, left, right);
        return (left as num) >= (right as num);
      case TokenType.less:
        _checkNumberOperands(expression.operator, left, right);
        return (left as num) < (right as num);
      case TokenType.lessEqual:
        _checkNumberOperands(expression.operator, left, right);
        return (left as num) <= (right as num);
      case TokenType.minus:
        _checkNumberOperands(expression.operator, left, right);
        return (left as num) - (right as num);
      case TokenType.slash:
        _checkNumberOperands(expression.operator, left, right);
        return (left as num) / (right as num);
      case TokenType.star:
        _checkNumberOperands(expression.operator, left, right);
        return (left as num) * (right as num);
      case TokenType.plus:
        if (left is num && right is num) {
          return left + right;
        } else if (left is String && right is String) {
          return '$left$right';
        }
        throw RuntimeError(
          token: expression.operator,
          message: 'Operands must be two numbers or two strings.',
        );
      case TokenType.bangEqual:
        return left != right;
      case TokenType.equalEqual:
        return left == right;
      default:
        // Unreachable.
        return null;
    }
  }

  @override
  Object? visitCallExpression(CallExpression expression) {
    final callee = _evaluate(expression.callee);

    final arguments = expression.arguments.map(_evaluate);

    if (callee is! Callable) {
      throw RuntimeError(
        token: expression.closingParenthesis,
        message: 'Can only call functions and classes.',
      );
    }

    if (arguments.length != callee.arity) {
      throw RuntimeError(
        token: expression.closingParenthesis,
        message:
            'Expected ${callee.arity} arguments but got ${arguments.length}.',
      );
    }

    return callee.call(this, arguments);
  }

  @override
  Object? visitGetExpression(GetExpression expression) {
    final object = _evaluate(expression.object);
    if (object is NtmInstance) {
      return object.get(expression.name);
    }
    throw RuntimeError(
      token: expression.name,
      message: 'Only instances have properties',
    );
  }

  @override
  Object? visitGroupingExpression(GroupingExpression expression) {
    return _evaluate(expression.expression);
  }

  @override
  Object? visitLiteralExpression(LiteralExpression expression) {
    return expression.value;
  }

  @override
  Object? visitLogicalExpression(LogicalExpression expression) {
    final left = _evaluate(expression.left);

    if (expression.operator.type == TokenType.pipePipe) {
      if (_isTruthy(left)) return left;
    } else {
      if (!_isTruthy(left)) return left;
    }
    return _evaluate(expression.right);
  }

  @override
  Object? visitSetExpression(SetExpression expression) {
    final object = _evaluate(expression.object);

    if (object is! NtmInstance) {
      throw RuntimeError(
        token: expression.name,
        message: 'Only instances have fields.',
      );
    }

    final value = _evaluate(expression.value);
    object.set(expression.name, value);
    return value;
  }

  @override
  Object? visitThisExpression(ThisExpression expression) {
    return _lookUpVariable(expression.keyword, expression);
  }

  @override
  Object? visitSuperExpression(SuperExpression expression) {
    final distance = _locals[expression]!;
    final superclass = _environment.getLexemeAt(distance, 'super') as NtmClass;

    // We do control the layout of the environment chains. The environment where
    // `this` is bound is always right inside the environment where we store
    // `super`.
    final object = _environment.getLexemeAt(
      distance - 1,
      'this',
    ) as NtmInstance;

    final method = superclass.findMethod(expression.method.lexeme);

    if (method == null) {
      errors.add(RuntimeError(
        token: expression.method,
        message: 'Undefined super property "${expression.method.lexeme}".',
      ));
      return null;
    } else {
      return method.bind(object);
    }
  }

  @override
  Object? visitUnaryExpression(UnaryExpression expression) {
    final right = _evaluate(expression.right);
    switch (expression.operator.type) {
      case TokenType.bang:
        return !_isTruthy(right);
      case TokenType.minus:
        _checkNumberOperand(expression.operator, right);
        return -(right as num);
      default:
        // Unreachable.
        return null;
    }
  }

  void _checkNumberOperand(Token operator, Object? operand) {
    if (operand is num) return;
    throw RuntimeError(token: operator, message: 'Operand must be a number.');
  }

  void _checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is num && right is num) return;
    throw RuntimeError(token: operator, message: 'Operands must be numbers.');
  }

  bool _isTruthy(Object? object) {
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  /// Helper method which simply sends the expression back into the
  /// interpreter’s visitor implementation.
  Object? _evaluate(Expression expression) {
    return expression.accept(this);
  }

  void _execute(Statement statement) {
    statement.accept(this);
  }

  void resolve(Expression expression, int depth) {
    _locals[expression] = depth;
  }

  void executeBlock(Iterable<Statement> statements, Environment environment) {
    final previousEnvironment = _environment;
    try {
      _environment = environment;
      for (final statement in statements) {
        _execute(statement);
      }
    } finally {
      _environment = previousEnvironment;
    }
  }

  @override
  void visitBlockStatement(BlockStatement statement) {
    executeBlock(statement.statements, Environment(enclosing: _environment));
  }

  @override
  void visitClassStatement(ClassStatement statement) {
    final Object? superclass;
    if (statement.superclass != null) {
      final potentialSuperClass = _evaluate(statement.superclass!);
      if (potentialSuperClass is! NtmClass) {
        errors.add(RuntimeError(
          token: statement.superclass!.name,
          message:
              'Superclass must be a class, but "${statement.superclass!.name.lexeme}" is not, so "${statement.name.lexeme}" cannot inherit from it.',
        ));
        superclass = null;
      } else {
        superclass = potentialSuperClass;
      }
    } else {
      superclass = null;
    }

    _environment.define(statement.name.lexeme, null);

    if (superclass != null) {
      _environment = Environment(enclosing: _environment);
      _environment.define('super', superclass);
    }

    final methods = Map.fromEntries(statement.methods.map((method) {
      return MapEntry(
        method.name.lexeme,
        NtmFunction(
          declaration: method,
          closure: _environment,
          isInitializer: method.name.lexeme == 'init',
        ),
      );
    }));
    final ntmClass = NtmClass(
      name: statement.name.lexeme,
      methods: methods,
      superclass: superclass as NtmClass?,
    );
    if (superclass != null) {
      _environment = _environment.enclosing!;
    }
    _environment.assign(statement.name, ntmClass);
  }

  @override
  void visitExpressionStatement(ExpressionStatement statement) {
    _evaluate(statement.expression);
  }

  @override
  void visitFunctionStatement(FunctionStatement statement) {
    final function = NtmFunction(
      declaration: statement,
      closure: _environment,
      isInitializer: false,
    );
    _environment.define(statement.name.lexeme, function);
  }

  @override
  void visitIfStatement(IfStatement statement) {
    if (_isTruthy(_evaluate(statement.condition))) {
      _execute(statement.thenBranch);
    } else if (statement.elseBranch != null) {
      _execute(statement.elseBranch!);
    }
  }

  @override
  void visitPrintStatement(PrintStatement statement) {
    final value = _evaluate(statement.expression);
    if (value is Describable) {
      stdout.writeln(value.describe());
    } else {
      stdout.writeln(value);
    }
  }

  @override
  void visitReturnStatement(ReturnStatement statement) {
    late final Object? value;
    if (statement.value != null) {
      value = _evaluate(statement.value!);
    } else {
      value = null;
    }
    throw ReturnException(value);
  }

  void interpret(Iterable<Statement> statements) {
    try {
      for (final statement in statements) {
        _execute(statement);
      }
    } on RuntimeError catch (error) {
      errors.add(error);
    }
  }

  @override
  void visitVarStatement(VarStatement statement) {
    if (statement.initializer != null) {
      final value = _evaluate(statement.initializer!);
      _environment.define(
        statement.name.lexeme,
        value,
      );
    } else {
      _environment.declare(statement.name.lexeme);
    }
  }

  @override
  void visitWhileStatement(WhileStatement statement) {
    while (_isTruthy(_evaluate(statement.condition))) {
      _execute(statement.body);
    }
  }

  @override
  Object? visitVariableExpression(VariableExpression expression) {
    return _lookUpVariable(expression.name, expression);
  }

  Object? _lookUpVariable(Token name, Expression expression) {
    // First, we look up the resolved distance in the map. We resolved only
    // local variables. Globals are treated specially and don’t end up in the
    // map (hence the name locals). So, if we don’t find a distance in the map,
    // it must be global. In that cases, we look it up, dynamically, directly in
    // the global environment. That throws a runtime error if the variable isn’t
    // defined.
    //
    // If we do get a distance, we have a local variable, and we get to take
    // advantage of the results of our static analysis.
    final distance = _locals[expression];
    if (distance != null) {
      return _environment.getAt(distance, name);
    } else {
      return globals.get(name);
    }
  }

  @override
  Object? visitAssignExpression(AssignExpression expression) {
    final value = _evaluate(expression.value);
    final distance = _locals[expression];
    if (distance != null) {
      _environment.assignAt(distance, expression.name, value);
    } else {
      globals.assign(expression.name, value);
    }
    return null;
  }
}

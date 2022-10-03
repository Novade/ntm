import 'package:equatable/equatable.dart';
import 'package:ntm_core/ntm_core.dart';

import 'expression.dart';

/// A visitor that can visit a statement.
abstract class StatementVisitor<T> {
  /// A visitor that can visit a statement.
  const StatementVisitor();

  /// Visits a block statement.
  T visitBlockStatement(BlockStatement statement);

  /// Visits a class statement.
  T visitClassStatement(ClassStatement statement);

  /// Visits an expression statement.
  T visitExpressionStatement(ExpressionStatement statement);

  /// Visits a function statement.
  T visitFunctionStatement(FunctionStatement statement);

  /// Visits an if statement.
  T visitIfStatement(IfStatement statement);

  /// Visits a print statement.
  T visitPrintStatement(PrintStatement statement);

  /// Visits a return statement.
  T visitReturnStatement(ReturnStatement statement);

  /// Visits a var statement.
  T visitVarStatement(VarStatement statement);

  /// Visits a while statement.
  T visitWhileStatement(WhileStatement statement);
}

/// A ntm statement.
abstract class Statement {
  /// A ntm statement.
  const Statement();

  /// Accept a visitor.
  T accept<T>(StatementVisitor<T> visitor);
}

/// {@template ntm.ast.block_statement}
/// A block statement.
///
/// ```ntm
/// {
///   a = b;
///   f();
/// }
/// ```
/// {@endtemplate}
class BlockStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.block_statement}
  const BlockStatement({
    this.statements = const [],
  });

  /// The list of statements.
  ///
  /// [`a = b;`, `f();`] in the example
  ///
  /// ```ntm
  /// {
  ///   a = b;
  ///   f();
  /// }
  /// ```
  final Iterable<Statement> statements;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitBlockStatement(this);
  }

  @override
  List<Object?> get props => statements.toList();
}

/// {@template ntm.ast.class_statement}
/// A class statement.
///
/// ```ntm
/// class A < B {
///   a() {}
///   b() {}
///   var c;
///   var d;
/// }
/// ```
/// {@endtemplate}
class ClassStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.class_statement}
  const ClassStatement({
    required this.name,
    required this.methods,
    required this.fields,
    this.superclass,
  });

  /// The name of the class.
  ///
  /// `A` in the example
  ///
  /// ```ntm
  /// class A {}
  /// ```
  final Token name;

  /// The list of methods.
  ///
  /// [`a() {}`, `b() {}`] in the example
  ///
  /// ```ntm
  /// class A {
  ///   a() {}
  ///   b() {}
  /// }
  /// ```
  final List<FunctionStatement> methods;

  /// The list fields.
  ///
  /// `['a', 'b']` in the example
  ///
  /// ```ntm
  /// class A {
  ///   var a;
  ///   var b;
  /// }
  /// ```
  final List<VarStatement> fields;

  /// The super class, if any.
  ///
  /// We store the superclass name as an [VariableExpression], not a [Token].
  /// The grammar restricts the superclass clause to a single identifier, but at
  /// runtime, that identifier is evaluated as a variable access. Wrapping the
  /// name in an [VariableExpression] early on in the parser gives us an object
  /// that the resolver can hang the resolution information off of.
  ///
  /// `B` in the example
  ///
  /// ```nmt
  /// class A < B {}
  /// ```
  final VariableExpression? superclass;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitClassStatement(this);
  }

  @override
  List<Object?> get props => [name, superclass, methods];
}

/// {@template ntm.ast.expression_statement}
/// An expression statement.
///
/// ```ntm
/// f();
/// 2;
/// ```
/// {@endtemplate}
class ExpressionStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.expression_statement}
  const ExpressionStatement(this.expression);

  /// The expression of the statement.
  ///
  /// `f()` in the example
  ///
  /// ```ntm
  /// f();
  /// ```
  final Expression expression;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitExpressionStatement(this);
  }

  @override
  List<Object?> get props => [expression];
}

/// {@template ntm.ast.function_statement}
/// A function statement.
///
/// ```ntm
/// function f(p1, p2) {
///   return p1 + p2;
/// }
/// ```
/// {@endtemplate}
class FunctionStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.function_statement}
  const FunctionStatement({
    required this.name,
    required this.params,
    required this.body,
  });

  /// The name of the function.
  ///
  /// `f` in the example
  ///
  /// ```ntm
  /// function f() {}
  /// ```
  final Token name;

  /// The list of parameters.
  ///
  /// [`p1`, `p2`] in the example
  ///
  /// ```ntm
  /// function f(p1, p2) {}
  /// ```
  final List<Token> params;

  /// The body of the function.
  ///
  /// `{ return p1 + p2; }` in the example
  ///
  /// ```ntm
  /// function f(p1, p2) {
  ///   return p1 + p2;
  /// }
  /// ```
  final List<Statement> body;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitFunctionStatement(this);
  }

  @override
  List<Object?> get props => [name, params, body];
}

/// {@template ntm.ast.if_statement}
/// An if statement.
///
/// ```ntm
/// if (a) {
///   b();
/// } else {
///   c();
/// }
/// ```
/// {@endtemplate}
class IfStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.if_statement}
  const IfStatement({
    required this.condition,
    required this.thenBranch,
    this.elseBranch,
  });

  /// The condition expression.
  ///
  /// `a` in the example
  /// ```ntm
  /// if (a) {
  ///   b();
  /// }
  /// ```
  final Expression condition;

  /// The "then" branch.
  ///
  /// `{ b(); }` in the example
  ///
  /// ```ntm
  /// if (a) {
  ///   b();
  /// } else {
  ///   c();
  /// }
  /// ```
  final Statement thenBranch;

  /// The "else" branch.
  ///
  /// `{ c(); }` in the example
  ///
  /// ```ntm
  /// if (a) {
  ///   b();
  /// } else {
  ///   c();
  /// }
  /// ```
  ///
  /// In can be `null` in the case of
  ///
  /// ```ntm
  /// if (a) {
  ///   b();
  /// }
  /// ```
  final Statement? elseBranch;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitIfStatement(this);
  }

  @override
  List<Object?> get props => [condition, thenBranch, elseBranch];
}

/// {@template ntm.ast.print_statement}
/// A print statement.
///
/// ```ntm
/// print 'Hello World';
/// ```
/// {@endtemplate}
class PrintStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.print_statement}
  const PrintStatement(this.expression);

  /// The expression of the statement.
  ///
  /// `'Hello World'` in the example
  ///
  /// ```ntm
  /// print 'Hello World';
  /// ```
  final Expression expression;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitPrintStatement(this);
  }

  @override
  List<Object?> get props => [expression];
}

/// {@template ntm.ast.return_statement}
/// A return statement.
///
/// ```ntm
/// return a;
/// ```
/// {@endtemplate}
class ReturnStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.return_statement}
  const ReturnStatement({
    required this.keyword,
    required this.value,
  });

  /// The `return` keyword.
  final Token keyword;

  /// The returned value.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// return a;
  /// ```
  ///
  /// It can be `null` in the case
  ///
  /// ```ntm
  /// return;
  /// ```
  final Expression? value;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitReturnStatement(this);
  }

  @override
  List<Object?> get props => [keyword, value];
}

/// {@template ntm.ast.var_statement}
/// A var statement.
///
/// ```ntm
/// var a = b;
/// var c;
/// ```
/// {@endtemplate}
class VarStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.var_statement}
  const VarStatement({
    required this.name,
    required this.initializer,
  });

  /// The name of the variable.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// var a = b;
  /// ```
  final Token name;

  /// The initializer of the variable if any.
  ///
  /// `b` in the example
  ///
  /// ```ntm
  /// var a = b;
  /// ```
  ///
  /// It can be `null` in the case of
  ///
  /// ```ntm
  /// var a;
  /// ```
  final Expression? initializer;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitVarStatement(this);
  }

  @override
  List<Object?> get props => [name, initializer];
}

/// {@template ntm.ast.while_statement}
/// A while statement.
///
/// ```ntm
/// while(a) {
///   f();
/// }
/// ```
/// {@endtemplate}
class WhileStatement extends Statement with EquatableMixin {
  /// {@macro ntm.ast.while_statement}
  const WhileStatement({
    required this.condition,
    required this.body,
  });

  /// The expression of the condition.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// while (a) {}
  /// ```
  final Expression condition;

  /// The body of the while.
  ///
  /// `{ f(); }` in the example
  ///
  /// ```ntm
  /// while (a) {
  ///   f();
  /// }
  /// ```
  final Statement body;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitWhileStatement(this);
  }

  @override
  List<Object?> get props => [condition, body];
}

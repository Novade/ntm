import 'package:ntm_core/ntm_core.dart';

/// A visitor that can visit an expression.
abstract class ExpressionVisitor<T> {
  /// A visitor that can visit an expression.
  const ExpressionVisitor();

  /// Visits an assign expression.
  T visitAssignExpression(AssignExpression expression);

  /// Visits a binary expression.
  T visitBinaryExpression(BinaryExpression expression);

  /// Visits a call expression.
  T visitCallExpression(CallExpression expression);

  /// Visits a get expression.
  T visitGetExpression(GetExpression expression);

  /// Visits a grouping expression.
  T visitGroupingExpression(GroupingExpression expression);

  /// Visits a literal expression.
  T visitLiteralExpression(LiteralExpression expression);

  /// Visits a logical expression.
  T visitLogicalExpression(LogicalExpression expression);

  /// Visits a set expression.
  T visitSetExpression(SetExpression expression);

  /// Visits a super expression.
  T visitSuperExpression(SuperExpression expression);

  /// Visits a this expression.
  T visitThisExpression(ThisExpression expression);

  /// Visits an unary expression.
  T visitUnaryExpression(UnaryExpression expression);

  /// Visits a variable expression.
  T visitVariableExpression(VariableExpression expression);
}

/// A ntm expression.
abstract class Expression {
  /// A ntm expression.
  const Expression();

  /// Accept a visitor.
  T accept<T>(ExpressionVisitor<T> visitor);
}

/// {@template ntm.ast.assign_expression}
/// An assign expression.
///
/// ```ntm
/// a = b
/// ```
/// {@endtemplate}
class AssignExpression extends Expression {
  /// {@macro ntm.ast.assign_expression}
  const AssignExpression({
    required this.name,
    required this.value,
  });

  /// The name of the variable being assigned.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// a = b
  /// ```
  final Token name;

  /// The value being assigned.
  ///
  /// `b` in the example
  ///
  /// ```ntm
  /// a = b
  /// ```
  final Expression value;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitAssignExpression(this);
  }
}

/// {@template ntm.ast.binary_expression}
/// A binary expression.
///
/// ```ntm
/// a + b
/// ```
/// {@endtemplate}
class BinaryExpression extends Expression {
  /// {@macro ntm.ast.binary_expression}
  const BinaryExpression({
    required this.left,
    required this.right,
    required this.operator,
  });

  /// The left expression.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// a + b
  /// ```
  final Expression left;

  /// The right expression.
  ///
  /// `b` in the example
  ///
  /// ```ntm
  /// a + b
  /// ```
  final Expression right;

  /// The operator.
  ///
  /// `+` in the example
  ///
  /// ```ntm
  /// a + b
  /// ```
  final Token operator;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitBinaryExpression(this);
  }
}

/// {@template ntm.ast.call_expression}
/// A call expression.
///
/// ```ntm
/// f(p1, p2)
/// ```
/// {@endtemplate}
class CallExpression extends Expression {
  /// {@macro ntm.ast.call_expression}
  const CallExpression({
    required this.callee,
    required this.closingParenthesis,
    required this.arguments,
  });

  /// The called.
  ///
  /// It is `f` in the example
  ///
  /// ```ntm
  /// f(p1, p2)
  /// ```
  final Expression callee;

  /// The token for the closing parenthesis. We use that token’s location when
  /// we report a runtime error caused by a function call.
  final Token closingParenthesis;

  /// The list of arguments.
  ///
  /// `[p1, p2]` in the example
  ///
  /// ```ntm
  /// f(p1, p2)
  /// ```
  final List<Expression> arguments;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitCallExpression(this);
  }
}

/// {@template ntm.ast.get_expression}
/// A get expression.
///
/// ```ntm
/// a.b
/// ```
/// {@endtemplate}
class GetExpression extends Expression {
  /// {@macro ntm.ast.get_expression}
  const GetExpression({
    required this.object,
    required this.name,
  });

  /// The object the get is applied on.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// a.b
  /// ```
  final Expression object;

  /// The name of the getter.
  ///
  /// `b` in the example
  ///
  /// ```ntm
  /// a.b
  /// ```
  final Token name;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitGetExpression(this);
  }
}

/// {@template ntm.ast.grouping_expression}
/// A grouping expression
///
/// ```ntm
/// (a + b)
/// ```
/// {@endtemplate}
class GroupingExpression extends Expression {
  /// {@macro ntm.ast.grouping_expression}
  const GroupingExpression({
    required this.expression,
  });

  /// The grouped expression.
  ///
  /// `a + b` in the example
  ///
  /// ```ntm
  /// (a + b)
  /// ```
  final Expression expression;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitGroupingExpression(this);
  }
}

/// {@template ntm.ast.literal_expression}
/// A literal expression.
///
/// ```ntm
/// 'hello world'
/// 1
/// ```
/// {@endtemplate}
class LiteralExpression extends Expression {
  /// {@macro ntm.ast.literal_expression}
  const LiteralExpression({
    required this.value,
  });

  /// The value of the literal.
  ///
  /// `1` in the example
  ///
  /// ```ntm
  /// 1
  /// ```
  final Object? value;
  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLiteralExpression(this);
  }
}

/// {@template ntm.ast.logical_expression}
/// A logical expression.
///
/// ```ntm
/// a || b
/// ```
/// {@endtemplate}
class LogicalExpression extends Expression {
  /// {@macro ntm.ast.logical_expression}
  const LogicalExpression({
    required this.left,
    required this.operator,
    required this.right,
  });

  /// The left operator.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// a || b
  /// ```
  final Expression left;

  /// The left operator.
  ///
  /// `||` in the example
  ///
  /// ```ntm
  /// a || b
  /// ```

  final Token operator;

  /// The left operator.
  ///
  /// `b` in the example
  ///
  /// ```ntm
  /// a || b
  /// ```

  final Expression right;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLogicalExpression(this);
  }
}

/// {@template ntm.ast.set_expression}
/// A set expression.
///
/// ```ntm
/// a.b = c
/// ```
/// {@endtemplate}
class SetExpression extends Expression {
  const SetExpression({
    required this.object,
    required this.name,
    required this.value,
  });

  /// The object of the setter.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// a.b = c
  /// ```
  final Expression object;

  /// The name of the setter.
  ///
  /// `b` in the example
  ///
  /// ```ntm
  /// a.b = c
  /// ```
  final Token name;

  /// The value being set.
  ///
  /// `c` in the example
  ///
  /// ```ntm
  /// a.b = c
  /// ```
  final Expression value;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitSetExpression(this);
  }
}

/// {@template ntm.ast.super_expression}
/// A super expression.
///
/// ```ntm
/// super.a
/// ```
/// {@endtemplate}
class SuperExpression extends Expression {
  /// {@macro ntm.ast.super_expression}
  const SuperExpression({
    required this.keyword,
    required this.method,
  });

  /// The `super` keyword.
  final Token keyword;

  /// The super method.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// super.a
  /// ```
  final Token method;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitSuperExpression(this);
  }
}

/// {@template ntm.ast.this_expression}
/// A this expression.
///
/// ```ntm
/// this
/// ```
/// {@endtemplate}
class ThisExpression extends Expression {
  /// {@macro ntm.ast.this_expression}
  const ThisExpression({
    required this.keyword,
  });

  /// The `this` keyword.
  final Token keyword;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitThisExpression(this);
  }
}

/// {@template ntm.ast.unary_expression}
/// An unary expression.
///
/// ```ntm
/// !a
/// ```
/// {@endtemplate}
class UnaryExpression extends Expression {
  /// {@macro ntm.ast.unary_expression}
  const UnaryExpression({
    required this.right,
    required this.operator,
  });

  /// The right expression.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// !a
  /// ```
  final Expression right;

  /// The operator.
  ///
  /// `!` in the example
  ///
  /// ```ntm
  /// !a
  /// ```
  final Token operator;
  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitUnaryExpression(this);
  }
}

/// {@template ntm.ast.variable.expression}
/// a variable expression.
///
/// ```ntm
/// var a
/// ```
/// {@endtemplate}
class VariableExpression extends Expression {
  /// {@macro ntm.ast.variable.expression}
  const VariableExpression(
    this.name,
  );

  /// The name of the variable.
  ///
  /// `a` in the example
  ///
  /// ```ntm
  /// var a
  /// ```
  final Token name;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitVariableExpression(this);
  }
}

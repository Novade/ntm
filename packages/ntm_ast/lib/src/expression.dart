import 'package:ntm_core/ntm_core.dart';

abstract class ExpressionVisitor<T> {
  const ExpressionVisitor();

  T visitBinaryExpression(BinaryExpression expression);
  T visitCallExpression(CallExpression expression);
  T visitGetExpression(GetExpression expression);
  T visitGroupingExpression(GroupingExpression expression);
  T visitLiteralExpression(LiteralExpression expression);
  T visitLogicalExpression(LogicalExpression expression);
  T visitSetExpression(SetExpression expression);
  T visitSuperExpression(SuperExpression expression);
  T visitThisExpression(ThisExpression expression);
  T visitUnaryExpression(UnaryExpression expression);
  T visitVariableExpression(VariableExpression expression);
  T visitAssignExpression(AssignExpression expression);
}

abstract class Expression {
  const Expression();
  T accept<T>(ExpressionVisitor<T> visitor);
}

class BinaryExpression extends Expression {
  const BinaryExpression({
    required this.left,
    required this.right,
    required this.operator,
  });
  final Expression left;
  final Expression right;
  final Token operator;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitBinaryExpression(this);
  }
}

class CallExpression extends Expression {
  const CallExpression({
    required this.callee,
    required this.closingParenthesis,
    required this.arguments,
  });

  final Expression callee;

  /// The token for the closing parenthesis. We use that token’s location when
  /// we report a runtime error caused by a function call.
  final Token closingParenthesis;
  final List<Expression> arguments;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitCallExpression(this);
  }
}

class GetExpression extends Expression {
  const GetExpression({
    required this.object,
    required this.name,
  });

  final Expression object;
  final Token name;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitGetExpression(this);
  }
}

class GroupingExpression extends Expression {
  const GroupingExpression({
    required this.expression,
  });
  final Expression expression;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitGroupingExpression(this);
  }
}

class LiteralExpression extends Expression {
  const LiteralExpression({
    required this.value,
  });
  final Object? value;
  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLiteralExpression(this);
  }
}

class LogicalExpression extends Expression {
  const LogicalExpression({
    required this.left,
    required this.operator,
    required this.right,
  });

  final Expression left;
  final Token operator;
  final Expression right;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLogicalExpression(this);
  }
}

class SetExpression extends Expression {
  const SetExpression({
    required this.object,
    required this.name,
    required this.value,
  });

  final Expression object;
  final Token name;
  final Expression value;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitSetExpression(this);
  }
}

class SuperExpression extends Expression {
  const SuperExpression({
    required this.keyword,
    required this.method,
  });

  final Token keyword;
  final Token method;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitSuperExpression(this);
  }
}

class ThisExpression extends Expression {
  const ThisExpression({
    required this.keyword,
  });

  final Token keyword;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitThisExpression(this);
  }
}

class UnaryExpression extends Expression {
  const UnaryExpression({
    required this.right,
    required this.operator,
  });
  final Expression right;
  final Token operator;
  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitUnaryExpression(this);
  }
}

class VariableExpression extends Expression {
  const VariableExpression(
    this.name,
  );

  final Token name;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitVariableExpression(this);
  }
}

class AssignExpression extends Expression {
  const AssignExpression({
    required this.name,
    required this.value,
  });

  final Token name;
  final Expression value;

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitAssignExpression(this);
  }
}

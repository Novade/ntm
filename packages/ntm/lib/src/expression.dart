import 'package:ntm/src/token.dart';

abstract class ExpressionVisitor<T> {
  const ExpressionVisitor();

  T visitBinaryExpression(BinaryExpression expression);
  T visitGroupingExpression(GroupingExpression expression);
  T visitLiteralExpression(LiteralExpression expression);
  T visitUnaryExpression(UnaryExpression expression);
  T visitVariableExpression(VariableExpression expression);
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

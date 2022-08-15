import 'package:ntm/src/token.dart';

abstract class Visitor<T> {
  const Visitor();

  T visitBinaryExpression(BinaryExpression expression);
  T visitGroupingExpression(GroupingExpression expression);
  T visitLiteralExpression(LiteralExpression expression);
  T visitUnaryExpression(UnaryExpression expression);
}

abstract class Expression {
  T accept<T>(Visitor<T> visitor);
}

class BinaryExpression extends Expression {
  BinaryExpression({
    required this.left,
    required this.right,
    required this.operator,
  });
  Expression left;
  Expression right;
  Token operator;

  @override
  T accept<T>(Visitor<T> visitor) {
    return visitor.visitBinaryExpression(this);
  }
}

class GroupingExpression extends Expression {
  GroupingExpression({
    required this.expression,
  });
  Expression expression;

  @override
  T accept<T>(Visitor<T> visitor) {
    return visitor.visitGroupingExpression(this);
  }
}

class LiteralExpression extends Expression {
  LiteralExpression({
    required this.value,
  });
  Object value;
  @override
  T accept<T>(Visitor<T> visitor) {
    return visitor.visitLiteralExpression(this);
  }
}

class UnaryExpression extends Expression {
  UnaryExpression({
    required this.right,
    required this.operator,
  });
  Expression right;
  Token operator;
  @override
  T accept<T>(Visitor<T> visitor) {
    return visitor.visitUnaryExpression(this);
  }
}

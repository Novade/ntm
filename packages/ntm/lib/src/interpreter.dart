import 'package:ntm/src/expression.dart';
import 'package:ntm/src/token_type.dart';

class Interpreter extends Visitor<Object?> {
  @override
  Object? visitBinaryExpression(BinaryExpression expression) {
    final left = _evaluate(expression.left);
    final right = _evaluate(expression.right);
    switch (expression.operator.type) {
      case TokenType.greater:
        return (left as double) > (right as double);
      case TokenType.greaterEqual:
        return (left as double) >= (right as double);
      case TokenType.less:
        return (left as double) < (right as double);
      case TokenType.lessEqual:
        return (left as double) <= (right as double);
      case TokenType.minus:
        return (left as double) - (right as double);
      case TokenType.slash:
        return (left as double) / (right as double);
      case TokenType.star:
        return (left as double) * (right as double);
      case TokenType.plus:
        if (left is double && right is double) {
          return left + right;
        } else if (left is String && right is String) {
          return '$left$right';
        }
        return null;
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
  Object? visitGroupingExpression(GroupingExpression expression) {
    return _evaluate(expression.expression);
  }

  @override
  Object? visitLiteralExpression(LiteralExpression expression) {
    return expression.value;
  }

  @override
  Object? visitUnaryExpression(UnaryExpression expression) {
    final right = _evaluate(expression.right);
    switch (expression.operator.type) {
      case TokenType.bang:
        return !_isTruthy(right);
      case TokenType.minus:
        return -(right as double);
      default:
        // Unreachable.
        return null;
    }
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
}

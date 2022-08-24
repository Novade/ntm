import 'dart:io';

import 'package:ntm/src/expression.dart';
import 'package:ntm/src/runtime_error.dart';
import 'package:ntm/src/token.dart';
import 'package:ntm/src/token_type.dart';

class Interpreter extends Visitor<Object?> {
  Interpreter();

  final errors = <RuntimeError>[];

  @override
  Object? visitBinaryExpression(BinaryExpression expression) {
    final left = _evaluate(expression.left);
    final right = _evaluate(expression.right);
    switch (expression.operator.type) {
      case TokenType.greater:
        _checkNumberOperands(expression.operator, left, right);
        return (left as double) > (right as double);
      case TokenType.greaterEqual:
        _checkNumberOperands(expression.operator, left, right);
        return (left as double) >= (right as double);
      case TokenType.less:
        _checkNumberOperands(expression.operator, left, right);
        return (left as double) < (right as double);
      case TokenType.lessEqual:
        _checkNumberOperands(expression.operator, left, right);
        return (left as double) <= (right as double);
      case TokenType.minus:
        _checkNumberOperands(expression.operator, left, right);
        return (left as double) - (right as double);
      case TokenType.slash:
        _checkNumberOperands(expression.operator, left, right);
        return (left as double) / (right as double);
      case TokenType.star:
        _checkNumberOperands(expression.operator, left, right);
        return (left as double) * (right as double);
      case TokenType.plus:
        if (left is double && right is double) {
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
        _checkNumberOperand(expression.operator, right);
        return -(right as double);
      default:
        // Unreachable.
        return null;
    }
  }

  void _checkNumberOperand(Token operator, Object? operand) {
    if (operand is double) return;
    throw RuntimeError(token: operator, message: 'Operand must be a number.');
  }

  void _checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is double && right is double) return;
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

  void interpret(Expression expression) {
    try {
      final value = _evaluate(expression);
      stdout.writeln(value);
    } on RuntimeError catch (error) {
      errors.add(error);
    }
  }
}

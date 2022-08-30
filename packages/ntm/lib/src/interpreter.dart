import 'dart:io';

import 'package:ntm/src/callable.dart';
import 'package:ntm/src/environment.dart';
import 'package:ntm/src/expression.dart';
import 'package:ntm/src/native_functions.dart';
import 'package:ntm/src/ntm_function.dart';
import 'package:ntm/src/runtime_error.dart';
import 'package:ntm/src/statement.dart';
import 'package:ntm/src/token.dart';
import 'package:ntm/src/token_type.dart';

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

  void _execute(Statement statement) {
    statement.accept(this);
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
  void visitExpressionStatement(ExpressionStatement statement) {
    _evaluate(statement.expression);
  }

  @override
  void visitFunctionStatement(FunctionStatement statement) {
    // TODO: Should we pass the current environment?
    final function = NtmFunction(declaration: statement);
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
    stdout.writeln(value);
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
    return _environment.get(expression.name);
  }

  @override
  Object? visitAssignExpression(AssignExpression expression) {
    final value = _evaluate(expression.value);
    _environment.assign(expression.name, value);
    return value;
  }
}

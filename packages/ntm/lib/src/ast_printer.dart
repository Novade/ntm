import 'package:ntm/src/expression.dart';

/// A visitor that produces an unambiguous string representation of the AST.
class AstPrint implements Visitor<String> {
  const AstPrint();
  String print(Expression expression) {
    return expression.accept(this);
  }

  @override
  String visitBinaryExpression(BinaryExpression expression) {
    return _parenthesis(
      expression.operator.lexeme,
      [expression.left, expression.right],
    );
  }

  @override
  String visitGroupingExpression(GroupingExpression expression) {
    return _parenthesis('group', [expression.expression]);
  }

  @override
  String visitLiteralExpression(LiteralExpression expression) {
    // TODO: What is the correct check? (Empty string?)
    if (expression.value == null) {
      return 'null';
    }
    return expression.value.toString();
  }

  @override
  String visitUnaryExpression(UnaryExpression expression) {
    return _parenthesis(expression.operator.lexeme, [expression.right]);
  }

  String _parenthesis(String name, Iterable<Expression> expressions) {
    final buffer = StringBuffer();
    buffer
      ..write('(')
      ..write(name);

    for (final expression in expressions) {
      buffer
        ..write(' ')
        ..write(expression.accept(this));
    }
    buffer.write(')');
    return buffer.toString();
  }
}

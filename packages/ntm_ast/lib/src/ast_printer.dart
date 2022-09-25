import 'expression.dart';
import 'statement.dart';

/// A visitor that produces an unambiguous string representation of the AST.
class AstPrinter
    implements ExpressionVisitor<String>, StatementVisitor<String> {
  /// A visitor that produces an unambiguous string representation of the AST.
  const AstPrinter();

  @override
  String visitBinaryExpression(BinaryExpression expression) {
    return _parenthesisExpression(
      expression.operator.lexeme,
      [expression.left, expression.right],
    );
  }

  @override
  String visitGroupingExpression(GroupingExpression expression) {
    return _parenthesisExpression('group', [expression.expression]);
  }

  @override
  String visitLiteralExpression(LiteralExpression expression) {
    if (expression.value == null) {
      return 'null';
    }
    return expression.value.toString();
  }

  @override
  String visitUnaryExpression(UnaryExpression expression) {
    return _parenthesisExpression(
        expression.operator.lexeme, [expression.right]);
  }

  String _parenthesisExpression(String name, Iterable<Expression> expressions) {
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

  @override
  String visitVariableExpression(VariableExpression expression) {
    return _parenthesisExpression('var', [expression]);
  }

  @override
  String visitAssignExpression(AssignExpression expression) {
    return _parenthesisExpression('assign', [expression.value]);
  }

  @override
  String visitLogicalExpression(LogicalExpression expression) {
    return _parenthesisExpression(
      expression.operator.lexeme,
      [expression.left, expression.right],
    );
  }

  @override
  String visitCallExpression(CallExpression expression) {
    return _parenthesisExpression(
      'call',
      [expression.callee, ...expression.arguments],
    );
  }

  @override
  String visitGetExpression(GetExpression expression) {
    return _parenthesisExpression(
      'get ${expression.name}',
      [expression.object],
    );
  }

  @override
  String visitSetExpression(SetExpression expression) {
    return _parenthesisExpression(
      'set ${expression.name}',
      [expression.object, expression.value],
    );
  }

  @override
  String visitThisExpression(ThisExpression expression) {
    return 'this';
  }

  @override
  String visitSuperExpression(SuperExpression expression) {
    return 'super.${expression.method.lexeme}';
  }

  String _parenthesisStatement(String name, Iterable<Statement> statements) {
    final buffer = StringBuffer();
    buffer
      ..write('(')
      ..write(name);

    for (final statement in statements) {
      buffer
        ..write(' ')
        ..write(statement.accept(this));
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  String visitBlockStatement(BlockStatement statement) {
    return _parenthesisStatement('block', statement.statements);
  }

  @override
  String visitClassStatement(ClassStatement statement) {
    final buffer = StringBuffer()..write('(class ${statement.name.lexeme} ');
    if (statement.superclass != null) {
      buffer.write('extends ${statement.superclass!.accept(this)} ');
    }
    if (statement.methods.isNotEmpty) {
      buffer
        ..write('(methods ')
        ..write([
          for (final method in statement.methods) method.accept(this),
        ].join(' '))
        ..write(')');
    }
    buffer.write(')');

    return buffer.toString();
  }

  @override
  String visitExpressionStatement(ExpressionStatement statement) {
    return _parenthesisExpression('expression', [statement.expression]);
  }

  @override
  String visitFunctionStatement(FunctionStatement statement) {
    return _parenthesisStatement(
      'function(${statement.params.map((param) => param.lexeme).join(', ')})',
      statement.body,
    );
  }

  @override
  String visitIfStatement(IfStatement statement) {
    final buffer = StringBuffer()
      ..write('(if ')
      ..write(_parenthesisExpression('condition', [statement.condition]))
      ..write(_parenthesisStatement('then', [statement.thenBranch]));
    if (statement.elseBranch != null) {
      buffer.write(_parenthesisStatement('else', [statement.elseBranch!]));
    }
    buffer.write(')');

    return buffer.toString();
  }

  @override
  String visitPrintStatement(PrintStatement statement) {
    return _parenthesisExpression('print', [statement.expression]);
  }

  @override
  String visitReturnStatement(ReturnStatement statement) {
    if (statement.value == null) {
      return '(return null)';
    }
    return _parenthesisExpression('return', [statement.value!]);
  }

  @override
  String visitVarStatement(VarStatement statement) {
    final buffer = StringBuffer()..write('var ${statement.name.lexeme}');
    if (statement.initializer != null) {
      buffer
        ..write(' = ')
        ..write(statement.initializer!.accept(this));
    }
    return buffer.toString();
  }

  @override
  String visitWhileStatement(WhileStatement statement) {
    final buffer = StringBuffer()
      ..write('(while ')
      ..write(_parenthesisExpression('condition', [statement.condition]))
      ..write(_parenthesisStatement('then', [statement.body]))
      ..write(')');
    return buffer.toString();
  }
}

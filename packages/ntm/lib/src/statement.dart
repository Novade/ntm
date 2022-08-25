import 'package:ntm/src/expression.dart';

abstract class Statement {
  const Statement();

  T accept<T>(StatementVisitor<T> visitor);
}

abstract class StatementVisitor<T> {
  const StatementVisitor();

  T visitExpressionStatement(ExpressionStatement statement);
  T visitPrintStatement(PrintStatement statement);
}

class ExpressionStatement extends Statement {
  const ExpressionStatement(this.expression);

  final Expression expression;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitExpressionStatement(this);
  }
}

class PrintStatement extends Statement {
  const PrintStatement(this.expression);

  final Expression expression;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitPrintStatement(this);
  }
}

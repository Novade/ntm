import 'package:ntm/src/expression.dart';
import 'package:ntm/src/token.dart';

abstract class Statement {
  const Statement();

  T accept<T>(StatementVisitor<T> visitor);
}

abstract class StatementVisitor<T> {
  const StatementVisitor();

  T visitExpressionStatement(ExpressionStatement statement);
  T visitPrintStatement(PrintStatement statement);
  T visitVarStatement(VarStatement statement);
  T visitBlockStatement(BlockStatement statement);
  T visitIfStatement(IfStatement statement);
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

class VarStatement extends Statement {
  const VarStatement({
    required this.name,
    required this.initializer,
  });

  final Token name;
  final Expression? initializer;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitVarStatement(this);
  }
}

class BlockStatement extends Statement {
  const BlockStatement({
    this.statements = const [],
  });

  final Iterable<Statement> statements;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitBlockStatement(this);
  }
}

class IfStatement extends Statement {
  const IfStatement({
    required this.condition,
    required this.thenBranch,
    this.elseBranch,
  });

  final Expression condition;
  final Statement thenBranch;
  final Statement? elseBranch;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitIfStatement(this);
  }
}

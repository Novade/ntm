import 'package:ntm/src/expression.dart';
import 'package:ntm/src/token.dart';

abstract class Statement {
  const Statement();

  T accept<T>(StatementVisitor<T> visitor);
}

abstract class StatementVisitor<T> {
  const StatementVisitor();

  T visitBlockStatement(BlockStatement statement);
  T visitClassStatement(ClassStatement statement);
  T visitExpressionStatement(ExpressionStatement statement);
  T visitPrintStatement(PrintStatement statement);
  T visitReturnStatement(ReturnStatement statement);
  T visitVarStatement(VarStatement statement);
  T visitFunctionStatement(FunctionStatement statement);
  T visitIfStatement(IfStatement statement);
  T visitWhileStatement(WhileStatement statement);
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

// TODO: Add fields.
class ClassStatement extends Statement {
  const ClassStatement({
    required this.name,
    required this.methods,
    this.superClass,
  });

  final Token name;
  final List<FunctionStatement> methods;

  /// The super class, if any.
  ///
  /// We store the superclass name as an [VariableExpression], not a [Token].
  /// The grammar restricts the superclass clause to a single identifier, but at
  /// runtime, that identifier is evaluated as a variable access. Wrapping the
  /// name in an Expr.Variable early on in the parser gives us an object that
  /// the resolver can hang the resolution information off of.
  final VariableExpression? superClass;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitClassStatement(this);
  }
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

class ReturnStatement extends Statement {
  const ReturnStatement({
    required this.keyword,
    required this.value,
  });

  final Token keyword;
  final Expression? value;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitReturnStatement(this);
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

class WhileStatement extends Statement {
  const WhileStatement({
    required this.condition,
    required this.body,
  });

  final Expression condition;
  final Statement body;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitWhileStatement(this);
  }
}

class FunctionStatement extends Statement {
  const FunctionStatement({
    required this.name,
    required this.params,
    required this.body,
  });

  final Token name;
  final List<Token> params;
  final List<Statement> body;

  @override
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitFunctionStatement(this);
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

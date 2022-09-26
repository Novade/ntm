import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_interpreter/ntm_interpreter.dart';

void main() {
  const ast = PrintStatement(
    LiteralExpression(
      value: 'Hello World',
    ),
  );
  Interpreter().interpret(const [ast]);
}

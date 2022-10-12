import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_interpreter/ntm_interpreter.dart';
import 'package:test/test.dart';

void main() {
  test('It should interpret the statement', () {
    const ast = PrintStatement(
      LiteralExpression(
        value: 'Hello World',
      ),
    );
    final logger = AccumulatorLogger();
    final interpreter = Interpreter(logger: logger);
    interpreter.interpret(const [ast]);

    expect(
      logger.logs,
      orderedEquals(['Hello World']),
    );
  });
}

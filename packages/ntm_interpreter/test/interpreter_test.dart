import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_interpreter/ntm_interpreter.dart';
import 'package:test/test.dart';

class _MockStdout extends Mock implements Stdout {}

void main() {
  test('It should interpret the statement', () {
    final stdout = _MockStdout();
    final stderr = _MockStdout();
    const ast = PrintStatement(
      LiteralExpression(
        value: 'Hello World',
      ),
    );
    final interpreter = Interpreter();
    IOOverrides.runZoned(
      () {
        interpreter.interpret(const [ast]);
      },
      stdout: () => stdout,
      stderr: () => stderr,
    );

    verify(() => stdout.writeln('Hello World')).called(1);
    verifyNever(() => stderr.writeln(any()));
  });
}

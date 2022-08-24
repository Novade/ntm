import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:ntm/ntm.dart';
import 'package:test/test.dart';

class _MockStdout extends Mock implements Stdout {}

void main() {
  test('It should evaluate 1 == 1 to true', () {
    final stdout = _MockStdout();
    final stderr = _MockStdout();
    IOOverrides.runZoned(
      () {
        Ntm().run('1 == 1');
      },
      stdout: () => stdout,
      stderr: () => stdout,
    );

    verify(() => stdout.writeln(true)).called(1);
    verifyNever(() => stderr.writeln(any()));
  });
  test('It should evaluate 1 != 1 to false', () {
    final stdout = _MockStdout();
    final stderr = _MockStdout();
    IOOverrides.runZoned(
      () {
        Ntm().run('1 != 1');
      },
      stdout: () => stdout,
      stderr: () => stdout,
    );

    verify(() => stdout.writeln(false)).called(1);
    verifyNever(() => stderr.writeln(any()));
  });
}

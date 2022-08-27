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
        Ntm().run('print 1 == 1;');
      },
      stdout: () => stdout,
      stderr: () => stderr,
    );

    verify(() => stdout.writeln(true)).called(1);
    verifyNever(() => stderr.writeln(any()));
  });
  test('It should evaluate 1 != 1 to false', () {
    final stdout = _MockStdout();
    final stderr = _MockStdout();
    IOOverrides.runZoned(
      () {
        Ntm().run('print 1 != 1;');
      },
      stdout: () => stdout,
      stderr: () => stderr,
    );

    verify(() => stdout.writeln(false)).called(1);
    verifyNever(() => stderr.writeln(any()));
  });

  group('Scope', () {
    test('It should scope variables', () {
      final stdout = _MockStdout();
      final stderr = _MockStdout();
      IOOverrides.runZoned(
        () {
          Ntm().run('''
var a = 'global a';
var b = 'global b';
var c = 'global c';
{
  var a = 'outer a';
  var b = 'outer b';
  {
    var a = 'inner a';
    print a;
    print b;
    print c;
  }
  print a;
  print b;
  print c;
}
print a;
print b;
print c;
''');
        },
        stdout: () => stdout,
        stderr: () => stderr,
      );

      final stdoutCaptured =
          verify(() => stdout.writeln(captureAny())).captured;
      expect(stdoutCaptured.join('\n'), '''
inner a
outer b
global c
outer a
outer b
global c
global a
global b
global c''');
      verifyNever(() => stderr.writeln(any()));
    });
  });

  group('Variable', () {
    test(
      'It should throw an error when a declared variable is being accessed without being assigned first',
      () {
        final stdout = _MockStdout();
        final stderr = _MockStdout();
        IOOverrides.runZoned(
          () {
            Ntm().run('''
var a;
print a;
''');
          },
          stdout: () => stdout,
          stderr: () => stderr,
        );

        verifyNever(() => stdout.writeln(any()));
        verify(() => stderr.writeln('''
The variable "a" was declared but never assigned.
[2:7]''')).called(1);
      },
    );
  });

  group('Control flow', () {
    group('if', () {
      test('it should evaluate the correct branch', () {
        final stdout = _MockStdout();
        final stderr = _MockStdout();
        IOOverrides.runZoned(
          () {
            Ntm().run('''
if (true) {
  print 'then 1';
} else {
  print 'else 1';
}

if (false) {
  print 'then 2';
} else {
  print 'else 2';
}
''');
          },
          stdout: () => stdout,
          stderr: () => stderr,
        );

        final stdoutCaptured = verify(
          () => stdout.writeln(captureAny()),
        ).captured;
        expect(
            stdoutCaptured,
            orderedEquals(
              ['then 1', 'else 2'],
            ));

        verifyNever(() => stderr.writeln(any()));
      });
    });
  });
}

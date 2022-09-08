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

  group('Logical operators', () {
    for (final left in const [true, false]) {
      for (final right in const [true, false]) {
        test('$left || $right should evaluate to ${left || right}', () {
          final stdout = _MockStdout();
          final stderr = _MockStdout();
          IOOverrides.runZoned(
            () {
              Ntm().run('print $left || $right;');
            },
            stdout: () => stdout,
            stderr: () => stderr,
          );

          verify(() => stdout.writeln(left || right)).called(1);
          verifyNever(() => stderr.writeln(any()));
        });

        test('$left && $right should evaluate to ${left && right}', () {
          final stdout = _MockStdout();
          final stderr = _MockStdout();
          IOOverrides.runZoned(
            () {
              Ntm().run('print $left && $right;');
            },
            stdout: () => stdout,
            stderr: () => stderr,
          );

          verify(() => stdout.writeln(left && right)).called(1);
          verifyNever(() => stderr.writeln(any()));
        });
      }
    }
  });

  group('While loops', () {
    test(
      'The while loop should loop on the body while the condition is true',
      () {
        final stdout = _MockStdout();
        final stderr = _MockStdout();
        IOOverrides.runZoned(
          () {
            Ntm().run('''
var a = 0;
while (a < 4) {
  print a;
  a = a + 1;
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
              const [0, 1, 2, 3],
            ));

        verifyNever(() => stderr.writeln(any()));
      },
    );
  });

  group('For loops', () {
    test(
      'It should loop 5 times and print the index',
      () {
        final stdout = _MockStdout();
        final stderr = _MockStdout();
        IOOverrides.runZoned(
          () {
            Ntm().run('''
for(var index = 0; index < 5; index = index + 1) {
  print index;
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
              const [0, 1, 2, 3, 4],
            ));

        verifyNever(() => stderr.writeln(any()));
      },
    );
  });

  group('Functions', () {
    test(
      'It should define an call the function',
      () {
        final stdout = _MockStdout();
        final stderr = _MockStdout();
        IOOverrides.runZoned(
          () {
            Ntm().run('''
fun f(first, last) {
  print 'prefix ' + first + ' infix ' + last + ' suffix';
}
f('one', 'two');
''');
          },
          stdout: () => stdout,
          stderr: () => stderr,
        );

        verify(() => stdout.writeln('prefix one infix two suffix')).called(1);
        verifyNever(() => stderr.writeln(any()));
      },
    );
  });

  group('Binary expressions', () {
    group('*', () {
      test(
        'It should multiply 2 numbers',
        () {
          final stdout = _MockStdout();
          final stderr = _MockStdout();
          IOOverrides.runZoned(
            () {
              Ntm().run('print 2 * 4;');
            },
            stdout: () => stdout,
            stderr: () => stderr,
          );

          verify(() => stdout.writeln(8)).called(1);
          verifyNever(() => stderr.writeln(any()));
        },
      );
    });
  });

  group('Resolver', () {
    group('Errors', () {
      test('It should report a return statement that is not in a function', () {
        final stdout = _MockStdout();
        final stderr = _MockStdout();
        IOOverrides.runZoned(
          () {
            Ntm().run('return 1;');
          },
          stdout: () => stdout,
          stderr: () => stderr,
        );

        verifyNever(() => stdout.writeln(any()));
        verify(
          () => stderr.writeln('[1:7] Cannot return from top-level code.'),
        ).called(1);
      });

      test(
          'It should report a variable that is already declared in the current scope',
          () {
        final stdout = _MockStdout();
        final stderr = _MockStdout();
        IOOverrides.runZoned(
          () {
            Ntm().run('''
{
  var a = 1;
  var a = 2;
}
''');
          },
          stdout: () => stdout,
          stderr: () => stderr,
        );

        verifyNever(() => stdout.writeln(any()));
        verify(
          () => stderr.writeln(
            '[3:7] There is already a variable with the name "a" in this scope.',
          ),
        ).called(1);
      });
    });

    test('It should report a variable that read itself', () {
      final stdout = _MockStdout();
      final stderr = _MockStdout();
      IOOverrides.runZoned(
        () {
          Ntm().run('''
var a = 0;
{
  var a = a;
}
''');
        },
        stdout: () => stdout,
        stderr: () => stderr,
      );

      verifyNever(() => stdout.writeln(any()));
      verify(
        () => stderr.writeln(
          '[3:11] Cannot read local variable in its own initializer.',
        ),
      ).called(1);
    });
  });

  group('Class', () {
    test('It should print the class', () {
      final stdout = _MockStdout();
      final stderr = _MockStdout();
      IOOverrides.runZoned(
        () {
          Ntm().run('''
class MyClass {
  myMethod() {
    return null;
  }
}

print MyClass;
''');
        },
        stdout: () => stdout,
        stderr: () => stderr,
      );

      verify(() => stdout.writeln('MyClass')).called(1);
      verifyNever(() => stderr.writeln(any()));
    });
  });
}

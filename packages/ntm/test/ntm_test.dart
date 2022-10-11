import 'package:ntm/ntm.dart';
import 'package:ntm_core/ntm_core.dart';
import 'package:test/test.dart';

void main() {
  test('It should evaluate 1 == 1 to true', () {
    final logger = AccumulatorLogger();
    Ntm(logger: logger).run('print 1 == 1;');
    expect(logger.logs, orderedEquals(const ['true']));
  });
  test('It should evaluate 1 != 1 to false', () {
    final logger = AccumulatorLogger();
    Ntm(logger: logger).run('print 1 != 1;');
    expect(logger.logs, orderedEquals(const ['false']));
  });

  group('Scope', () {
    test('It should scope variables', () {
      final logger = AccumulatorLogger();
      Ntm(logger: logger).run('''
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

      expect(
        logger.logs,
        orderedEquals([
          'inner a',
          'outer b',
          'global c',
          'outer a',
          'outer b',
          'global c',
          'global a',
          'global b',
          'global c',
        ]),
      );
    });
  });

  group('Variable', () {
    test(
      'It should throw an error when a declared variable is being accessed without being assigned first',
      () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
var a;
print a;
''');

        expect(
          logger.logs,
          orderedEquals(const [
            '[2:7] The variable "a" was declared but never assigned.'
          ]),
        );
      },
    );
  });

  group('Control flow', () {
    group('if', () {
      test('it should evaluate the correct branch', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
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

        expect(logger.logs, orderedEquals(const ['then 1', 'else 2']));
      });
    });
  });

  group('Logical operators', () {
    for (final left in const [true, false]) {
      for (final right in const [true, false]) {
        test('$left || $right should evaluate to ${left || right}', () {
          final logger = AccumulatorLogger();
          Ntm(logger: logger).run('print $left || $right;');
          expect(logger.logs, orderedEquals([(left || right).toString()]));
        });

        test('$left && $right should evaluate to ${left && right}', () {
          final logger = AccumulatorLogger();
          Ntm(logger: logger).run('print $left && $right;');
          expect(logger.logs, orderedEquals([(left && right).toString()]));
        });
      }
    }
  });

  group('While loops', () {
    test(
      'The while loop should loop on the body while the condition is true',
      () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
var a = 0;
while (a < 4) {
  print a;
  a = a + 1;
}
''');

        expect(logger.logs, orderedEquals(const ['0', '1', '2', '3']));
      },
    );
  });

  group('For loops', () {
    test(
      'It should loop 5 times and print the index',
      () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
for(var index = 0; index < 5; index = index + 1) {
  print index;
}
''');

        expect(logger.logs, orderedEquals(const ['0', '1', '2', '3', '4']));
      },
    );
  });

  group('Functions', () {
    test(
      'It should define an call the function',
      () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
fun f(first, last) {
  print 'prefix ' + first + ' infix ' + last + ' suffix';
}
f('one', 'two');
''');

        expect(
          logger.logs,
          orderedEquals(const ['prefix one infix two suffix']),
        );
      },
    );
  });

  group('Binary expressions', () {
    group('*', () {
      test(
        'It should multiply 2 numbers',
        () {
          final logger = AccumulatorLogger();
          Ntm(logger: logger).run('print 2 * 4;');

          expect(logger.logs, orderedEquals(const ['8']));
        },
      );
    });
  });

  group('Resolver', () {
    group('Errors', () {
      test('It should report a return statement that is not in a function', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('return 1;');
        expect(
          logger.logs,
          orderedEquals(const ['[1:7] Cannot return from top-level code.']),
        );
      });

      test(
          'It should report a variable that is already declared in the current scope',
          () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
{
  var a = 1;
  var a = 2;
}
''');
        expect(
          logger.logs,
          orderedEquals(const [
            '[3:7] There is already a variable with the name "a" in this scope.'
          ]),
        );
      });
    });

    test('It should report a variable that read itself', () {
      final logger = AccumulatorLogger();
      Ntm(logger: logger).run('''
var a = 0;
{
  var a = a;
}
''');
      expect(
        logger.logs,
        orderedEquals(const [
          '[3:11] Cannot read local variable in its own initializer.'
        ]),
      );
    });
  });

  group('Class', () {
    test('It should print the class', () {
      final logger = AccumulatorLogger();
      Ntm(logger: logger).run('''
class MyClass {
  myMethod() {
    return null;
  }
}

print MyClass;
var myInstance = MyClass();
print myInstance;
''');
      expect(
        logger.logs,
        orderedEquals(const ['MyClass', 'MyClass instance']),
      );
    });
    group('Field', () {
      test('It should set and get the class field', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {
  var myField;
}
var myInstance = MyClass();
myInstance.myField = 'myValue';
print myInstance.myField;
''');
        expect(
          logger.logs,
          orderedEquals(const ['myValue']),
        );
      });

      test(
          'It should raise an error when a field that does not exist is accessed',
          () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {}
var myInstance = MyClass();
myInstance.myField;
''');
        expect(
          logger.logs,
          orderedEquals(const ['[3:18] Undefined property "myField".']),
        );
      });

      test(
          'It should raise an error when a field that has not been initialized is accessed',
          () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {
  var myField;
}
var myInstance = MyClass();
myInstance.myField;
''');
        expect(
          logger.logs,
          orderedEquals(
            const ['[5:18] The field "myField" is not initialized.'],
          ),
        );
      });

      test('It should initialize a field with an initializer', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {
  var a;
  var b = 2;
}

var instance = MyClass();
print instance.b;
''');
        expect(logger.logs, orderedEquals(const ['2']));
      });
      test(
        'It should initialize a field with an initializer when the instance is created',
        () {
          final logger = AccumulatorLogger();
          Ntm(logger: logger).run('''
var variable = 1;
class MyClass {
  var a = variable;
}

var instance = MyClass();
print instance.a;
variable = 2;
instance = MyClass();
print instance.a;
''');
          expect(
            logger.logs,
            orderedEquals(const ['1', '2']),
          );
        },
      );
      test(
        'It should initialize a field with an initializer referring to the correct variable when the instance is created',
        () {
          final logger = AccumulatorLogger();
          Ntm(logger: logger).run('''
var variable = 1;
class MyClass {
  var a = variable;
}
{
  var instance = MyClass();
  print instance.a;
  variable = 2;
  instance = MyClass();
  print instance.a;
  var variable = 3;
  {
    var variable = 4;
    instance = MyClass();
    print instance.a;
  }
}
''');
          expect(
            logger.logs,
            orderedEquals(const ['1', '2', '2']),
          );
        },
      );
    });

    group('Method', () {
      test('It should access the method of the class', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {
  method() {
    print 'method';
  }
}
MyClass().method();
''');
        expect(logger.logs, orderedEquals(const ['method']));
      });

      test('It should be able to access this', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {
  var field = 'field';
  method() {
    print this.field + ' in method';
  }
}
var instance = MyClass();
instance.method();
''');
        expect(logger.logs, orderedEquals(const ['field in method']));
      });

      test('It should not allow to access "this" when not in a class', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('this;');
        expect(
          logger.logs,
          orderedEquals(const ['[1:5] Cannot use "this" outside a class.']),
        );
      });
    });

    group('init', () {
      test('It should init the field when the instance is created', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {
  var field0;
  var field1;
  init(field1) {
    this.field0 = 'field0';
    this.field1 = field1;
  }
}
var instance = MyClass(2);
print instance.field0;
print instance.field1;
''');
        expect(logger.logs, orderedEquals(const ['field0', '2']));
      });

      test('It should raise an error if the init method returns a value', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {
  init(field1) {
    return 2;
  }
}
''');
        expect(
          logger.logs,
          orderedEquals(
            const ['[3:10] Cannot return a value from an initializer.'],
          ),
        );
      });

      test('It should accept empty return in the init method', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class MyClass {
  init(field1) {
    return;
  }
}
''');
        expect(logger.logs, orderedEquals(const []));
      });
    });

    group('Inheritance', () {
      test('It should inherit the method from the super class', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
class SuperClass {
  superMethod() {
    print 'superMethod';
  }
}

class SubClass < SuperClass {
  subMethod() {
    print 'subMethod';
  }
}

var instance = SubClass();
instance.superMethod();
instance.subMethod();
''');
        expect(
          logger.logs,
          orderedEquals(const ['superMethod', 'subMethod']),
        );
      });

      test('It should only allow class to inherit from another class', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('''
var NotAClass = 'I am totally not a class';

class Subclass < NotAClass {}
''');
        expect(
          logger.logs,
          orderedEquals(const [
            '[3:26] Superclass must be a class, but "NotAClass" is not, so "Subclass" cannot inherit from it.',
          ]),
        );
      });

      test('It should not allow a class to extend itself', () {
        final logger = AccumulatorLogger();
        Ntm(logger: logger).run('class MyClass < MyClass {}');
        expect(
          logger.logs,
          orderedEquals(
            const ['[1:24] Class "MyClass" cannot inherit from itself.'],
          ),
        );
      });

      group('super', () {
        test('It should call the super method', () {
          final logger = AccumulatorLogger();
          Ntm(logger: logger).run('''
class SuperClass {
  method() {
    print 'superMethod';
  }
}

class SubClass < SuperClass {
  method() {
    super.method();
    print 'subMethod';
  }
}

var instance = SubClass();
instance.method();
''');
          expect(
            logger.logs,
            orderedEquals(const ['superMethod', 'subMethod']),
          );
        });

        test(
          'It throw an error when calling a super method that does not exist',
          () {
            final logger = AccumulatorLogger();
            Ntm(logger: logger).run('''
class SuperClass {}

class SubClass < SuperClass {
  method() {
    super.method();
  }
}

var instance = SubClass();
instance.method();
''');
            expect(
              logger.logs,
              orderedEquals(
                const [
                  '[5:16] Undefined super property "method".',
                  '[5:18] Can only call functions and classes.'
                ],
              ),
            );
          },
        );

        test('It throw an error when super is used outside a class', () {
          final logger = AccumulatorLogger();
          Ntm(logger: logger).run('super.method();');
          expect(
            logger.logs,
            orderedEquals(
              const ['[1:6] Cannot use "super" outside of a class.'],
            ),
          );
        });

        test(
          'It throw an error when super is used in a class that do not extend another class',
          () {
            final logger = AccumulatorLogger();
            Ntm(logger: logger).run('''
class MyClass {
  method() {
    super.method();
  }
}
''');
            expect(
              logger.logs,
              orderedEquals(const [
                '[3:9] Cannot use "super" in a class with no superclass.',
              ]),
            );
          },
        );
      });
    });
  });
}

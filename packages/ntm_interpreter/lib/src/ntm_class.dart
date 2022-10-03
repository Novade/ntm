import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_core/ntm_core.dart';

import 'callable.dart';
import 'interpreter.dart';
import 'ntm_function.dart';
import 'ntm_instance.dart';

// TODO: Add support to static method
// https://www.craftinginterpreters.com/classes.html#challenges (`NtmClass`
// could extends `NtmInstance`).

/// A class in the Ntm language.x
class NtmClass implements Describable, Callable {
  /// A class in the Ntm language.
  const NtmClass({
    required this.name,
    required this.methods,
    required this.fields,
    this.superclass,
  });

  /// The name of the class
  final String name;

  /// The methods of the class.
  final Map<String, NtmFunction> methods;

  /// The fields of the class.
  final Map<String, VarStatement> fields;

  /// The super class.
  final NtmClass? superclass;

  @override
  int get arity {
    // If there is an initializer, that method’s arity determines how many
    // arguments you must pass when you call the class itself. We don’t require
    // a class to define an initializer, though, as a convenience. If you don’t
    // have an initializer, the arity is still zero.
    final initializer = findMethod('init');
    return initializer?.arity ?? 0;
  }

  /// Finds the method with the given [name].
  NtmFunction? findMethod(String name) {
    if (methods.containsKey(name)) {
      return methods[name]!;
    }
    return superclass?.findMethod(name);
  }

  /// Returns `true` if the class contains a field with the given [name].
  bool hasField(String name) {
    if (fields.containsKey(name)) {
      return true;
    }
    return superclass?.hasField(name) ?? false;
  }

  void _initFields(NtmInstance instance, Interpreter interpreter) {
    superclass?._initFields(instance, interpreter);
    for (final fieldInitializer in fields.values) {
      if (fieldInitializer.initializer != null) {
        final value = interpreter.evaluate(
          fieldInitializer.initializer!,
        );
        instance.set(fieldInitializer.name, value);
      }
    }
  }

  @override
  Object? call(Interpreter interpreter, Iterable<Object?> arguments) {
    final instance = NtmInstance(this);
    _initFields(instance, interpreter);
    // When a class is called, after the LoxInstance is created, we look for an
    // “init” method. If we find one, we immediately bind and invoke it just
    // like a normal method call. The argument list is forwarded along.
    final initializer = findMethod('init');
    if (initializer != null) {
      initializer.bind(instance).call(interpreter, arguments);
    }
    return instance;
  }

  @override
  String describe() {
    return name;
  }
}

import 'package:ntm_core/ntm_core.dart';

import 'callable.dart';
import 'interpreter.dart';
import 'ntm_function.dart';
import 'ntm_instance.dart';

// TODO: Add support to static method, fields
// https://www.craftinginterpreters.com/classes.html#challenges (`NtmClass`
// could extends `NtmInstance`).

class NtmClass implements Describable, Callable {
  const NtmClass({
    required this.name,
    required this.methods,
    this.superclass,
  });

  final String name;
  final Map<String, NtmFunction> methods;
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

  NtmFunction? findMethod(String name) {
    if (methods.containsKey(name)) {
      return methods[name]!;
    }
    return superclass?.findMethod(name);
  }

  @override
  Object? call(Interpreter interpreter, Iterable<Object?> arguments) {
    final instance = NtmInstance(this);
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
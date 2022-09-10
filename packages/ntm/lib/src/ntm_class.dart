import 'package:ntm/src/callable.dart';
import 'package:ntm/src/describable.dart';
import 'package:ntm/src/interpreter.dart';
import 'package:ntm/src/ntm_function.dart';
import 'package:ntm/src/ntm_instance.dart';

class NtmClass implements Describable, Callable {
  const NtmClass({
    required this.name,
    required this.methods,
  });

  final String name;
  final Map<String, NtmFunction> methods;

  @override
  int get arity => 0;

  NtmFunction? findMethod(String name) {
    if (methods.containsKey(name)) {
      return methods[name]!;
    }
    return null;
  }

  @override
  Object? call(Interpreter interpreter, Iterable<Object?> arguments) {
    return NtmInstance(this);
  }

  @override
  String describe() {
    return name;
  }
}

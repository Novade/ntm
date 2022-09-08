import 'package:ntm/src/callable.dart';
import 'package:ntm/src/describable.dart';
import 'package:ntm/src/interpreter.dart';
import 'package:ntm/src/ntm_instance.dart';

class NtmClass implements Describable, Callable {
  const NtmClass(this.name);

  final String name;

  @override
  int get arity => 0;

  @override
  Object? call(Interpreter interpreter, Iterable<Object?> arguments) {
    return NtmInstance(this);
  }

  @override
  String describe() {
    return name;
  }
}

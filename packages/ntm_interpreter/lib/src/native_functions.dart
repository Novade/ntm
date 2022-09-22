import 'callable.dart';
import 'interpreter.dart';

// TODO: Make printe a native method.

class Clock extends Callable {
  const Clock();
  @override
  int get arity => 0;

  @override
  Object? call(Interpreter interpreter, Iterable<Object?> arguments) {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String describe() => '<native fn>';
}

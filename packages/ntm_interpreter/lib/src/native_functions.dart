import 'callable.dart';
import 'interpreter.dart';

// TODO: Make print a native method.

/// A native method that returns the milliseconds since epoch.
class Clock extends Callable {
  /// A native method that returns the milliseconds since epoch.
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

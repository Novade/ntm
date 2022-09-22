import 'package:ntm_interpreter/src/interpreter.dart';

abstract class Callable {
  const Callable();

  /// Fancy term for the number of arguments a function or operation expects.
  int get arity;
  Object? call(Interpreter interpreter, Iterable<Object?> arguments);

  String describe();
}

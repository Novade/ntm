import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_interpreter/src/interpreter.dart';

/// An object that can be called.
abstract class Callable extends Describable {
  /// An object that can be called.
  const Callable();

  /// Fancy term for the number of arguments a function or operation expects.
  int get arity;

  /// Call the object.
  Object? call(Interpreter interpreter, Iterable<Object?> arguments);

  @override
  String describe();
}

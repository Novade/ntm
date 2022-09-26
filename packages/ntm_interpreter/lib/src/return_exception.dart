/// {@template ntm.interpreter.return_exception}
/// An exception thrown when a return statement is encountered.
///
/// It is used to unwind the interpreter past the visit methods of all of the
/// containing statements back to the code that began executing the body.
/// {@endtemplate}
class ReturnException implements Exception {
  /// {@macro ntm.interpreter.return_exception}
  const ReturnException(this.value);

  /// The value being returned.
  final Object? value;
}

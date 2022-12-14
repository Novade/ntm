import 'package:ntm_core/ntm_core.dart';

/// A runtime error raised by the interpreter.
class RuntimeError implements DescribableError {
  /// A runtime error raised by the interpreter.
  const RuntimeError({
    required this.token,
    required this.message,
  });

  /// The token.
  final Token token;

  /// The error message.
  final String message;

  @override
  String describe() {
    return '[${token.line}:${token.column}] $message';
  }
}

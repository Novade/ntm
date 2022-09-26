import 'package:ntm_core/ntm_core.dart';

/// An error raised by the resolver.
class ResolverError extends DescribableError {
  /// An error raised by the resolver.
  const ResolverError({
    required this.token,
    required this.message,
  });

  /// The token of the error.
  final Token token;

  /// The message of the error.
  final String message;

  @override
  String describe() {
    return '[${token.line}:${token.column}] $message';
  }
}

import 'package:ntm_core/ntm_core.dart';

/// {@template ntm.parser.parse_error}
/// An error that occurred during the parsing.
///
/// Contains the [token] and error [message].
/// {@endtemplate}
class ParseError extends DescribableError {
  /// {@macro ntm.parser.parse_error}
  const ParseError({
    required this.token,
    required this.message,
  });

  /// The token that threw the error.
  final Token token;

  /// The error message.
  final String message;

  @override
  String describe() {
    final String where;
    if (token.type == TokenType.eof) {
      where = 'at end';
    } else {
      where = 'at "${token.lexeme}"';
    }
    return '[line ${token.line}:${token.column}] Error $where: $message';
  }

  @override
  String toString() {
    return '''
ParseError(
  token: $token,
  message: $message,
)''';
  }
}

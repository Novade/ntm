import 'package:ntm/src/descriptive_error.dart';
import 'package:ntm/src/token_type.dart';

/// Stores the information about a token.
class Token {
  const Token({
    required this.type,
    required this.line,
    required this.column,
    this.lexeme = '',
    this.literal,
  });

  final TokenType type;
  final String lexeme;
  final int line;
  final int column;
  final Object? literal;

  String describe() {
    return '$type $lexeme $literal';
  }
}

class TokenError extends DescriptiveError {
  const TokenError({
    required this.line,
    required this.column,
    required this.message,
  });
  final int line;
  final int column;
  final String message;

  @override
  String describe() {
    return '[$line:$column]: $message';
  }
}

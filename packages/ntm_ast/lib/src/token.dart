import 'package:ntm_ast/src/token_type.dart';
import 'package:ntm_core/ntm_core.dart';

/// Stores the information about a token.
class Token extends Describable {
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

  @override
  String describe() {
    return '$type $lexeme $literal';
  }
}

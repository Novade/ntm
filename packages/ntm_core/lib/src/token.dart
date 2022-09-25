import 'package:equatable/equatable.dart';

import 'describable.dart';
import 'token_type.dart';

/// Stores the information about a token.
class Token extends Describable with EquatableMixin {
  const Token({
    required this.type,
    required this.line,
    required this.column,
    this.lexeme = '',
    this.literal,
  });

  /// The token type.
  final TokenType type;

  /// The lexeme of the token. For literals ([TokenType.string],
  /// [TokenType.number]) it stores the value of written by the user. For
  /// identifier ([TokenType.identifier]), this is the name of the identifier.
  final String lexeme;

  /// The line of the token.
  final int line;

  /// The column of the token.
  final int column;

  /// The value of the literal. For [TokenType.string], it is a [String], for
  /// [TokenType.number], it is a [num].
  final Object? literal;

  @override
  String describe() {
    return '$type $lexeme $literal';
  }

  @override
  String toString() {
    return '''
Token(
  type: $type,
  lexeme: $lexeme,
  literal: $literal,
  line: $line,
  column: $column,
)''';
  }

  @override
  List<Object?> get props => [type, lexeme, line, column, literal];
}

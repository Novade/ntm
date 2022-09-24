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

  final TokenType type;
  final String lexeme;
  final int line;
  final int column;
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

import 'package:equatable/equatable.dart';
import 'package:ntm_ast/ntm_ast.dart';

import 'parse_error.dart';

/// The result of the ntm parser.
class ParseResult with EquatableMixin {
  /// The result of the ntm parser.
  const ParseResult({
    this.statements = const [],
    this.errors = const [],
  });

  /// The list of statements.
  final List<Statement> statements;

  /// The list of parse errors.
  final List<ParseError> errors;

  @override
  List<Object?> get props => [statements, errors];

  @override
  String toString() {
    return '''
ParseResult(
  statements: $statements,
  errors: $errors,
)''';
  }
}

import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_parser/ntm_parser.dart';
import 'package:test/test.dart';

void main() {
  test('It should return a readable error message', () {
    final error = ParseError(
      token: Token(
        line: 1,
        column: 2,
        type: TokenType.dot,
        lexeme: 'lexeme',
      ),
      message: 'Error message.',
    );

    expect(error.describe(), '[line 1:2] Error at "lexeme": Error message.');
  });
}

import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_parser/ntm_parser.dart';
import 'package:test/test.dart';

void main() {
  test('It should boolean literal expression', () {
    final parser = Parser(
      tokens: [
        Token(
          type: TokenType.falseKeyword,
          line: 1,
          column: 1,
        ),
        Token(
          type: TokenType.semicolon,
          line: 1,
          column: 2,
        ),
        Token(
          type: TokenType.eof,
          line: 1,
          column: 3,
        ),
      ],
    );

    final parseResult = parser.parse();
    expect(
      parseResult,
      const ParseResult(
        statements: [
          ExpressionStatement(LiteralExpression(value: false)),
        ],
      ),
    );
  });

  test('It should string literal expression', () {
    final parser = Parser(
      tokens: [
        Token(
          type: TokenType.string,
          line: 1,
          column: 1,
          literal: 'myString',
        ),
        Token(
          type: TokenType.semicolon,
          line: 1,
          column: 2,
        ),
        Token(
          type: TokenType.eof,
          line: 1,
          column: 3,
        ),
      ],
    );

    final parseResult = parser.parse();
    expect(
      parseResult,
      const ParseResult(
        statements: [
          ExpressionStatement(LiteralExpression(value: 'myString')),
        ],
      ),
    );
  });
}

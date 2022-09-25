import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_parser/ntm_parser.dart';

void main() {
  final parser = Parser(
    tokens: [
      Token(
        type: TokenType.printKeyword,
        lexeme: 'print',
        literal: null,
        line: 1,
        column: 6,
      ),
      Token(
        type: TokenType.string,
        lexeme: "'Hello World'",
        literal: 'Hello World',
        line: 1,
        column: 20,
      ),
      Token(
        type: TokenType.semicolon,
        lexeme: ';',
        literal: null,
        line: 1,
        column: 21,
      ),
      Token(
        type: TokenType.eof,
        literal: null,
        line: 1,
        column: 21,
      ),
    ],
  );

  final parseResult = parser.parse();
  print(parseResult);
}

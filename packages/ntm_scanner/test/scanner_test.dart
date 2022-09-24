import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_scanner/ntm_scanner.dart';
import 'package:ntm_scanner/src/scan_result.dart';
import 'package:test/test.dart';

void main() {
  test('It should scan a print statement', () {
    final source = 'print 2;';
    final scanner = Scanner(source: source);
    final scanResult = scanner.scanTokens();

    expect(
      scanResult,
      const ScanResult(
        tokens: [
          Token(
            type: TokenType.printKeyword,
            lexeme: 'print',
            line: 1,
            column: 6,
          ),
          Token(
            type: TokenType.number,
            lexeme: '2',
            line: 1,
            column: 8,
            literal: 2,
          ),
          Token(
            type: TokenType.semicolon,
            lexeme: ';',
            line: 1,
            column: 9,
          ),
          Token(
            type: TokenType.eof,
            line: 1,
            column: 9,
          ),
        ],
      ),
    );
  });

  test('It should scan a simple method', () {
    final source = '''
fun add(a, b) {
  return a + b;
}
''';
    final scanner = Scanner(source: source);
    final scanResult = scanner.scanTokens();

    expect(
      scanResult,
      const ScanResult(
        tokens: [
          Token(
            type: TokenType.funKeyword,
            lexeme: 'fun',
            literal: null,
            line: 1,
            column: 4,
          ),
          Token(
            type: TokenType.identifier,
            lexeme: 'add',
            literal: null,
            line: 1,
            column: 8,
          ),
          Token(
            type: TokenType.leftParenthesis,
            lexeme: '(',
            literal: null,
            line: 1,
            column: 9,
          ),
          Token(
            type: TokenType.identifier,
            lexeme: 'a',
            literal: null,
            line: 1,
            column: 10,
          ),
          Token(
            type: TokenType.comma,
            lexeme: ',',
            literal: null,
            line: 1,
            column: 11,
          ),
          Token(
            type: TokenType.identifier,
            lexeme: 'b',
            literal: null,
            line: 1,
            column: 13,
          ),
          Token(
            type: TokenType.rightParenthesis,
            lexeme: ')',
            literal: null,
            line: 1,
            column: 14,
          ),
          Token(
            type: TokenType.leftBrace,
            lexeme: '{',
            literal: null,
            line: 1,
            column: 16,
          ),
          Token(
            type: TokenType.returnKeyword,
            lexeme: 'return',
            literal: null,
            line: 2,
            column: 8,
          ),
          Token(
            type: TokenType.identifier,
            lexeme: 'a',
            literal: null,
            line: 2,
            column: 10,
          ),
          Token(
            type: TokenType.plus,
            lexeme: '+',
            literal: null,
            line: 2,
            column: 12,
          ),
          Token(
            type: TokenType.identifier,
            lexeme: 'b',
            literal: null,
            line: 2,
            column: 14,
          ),
          Token(
            type: TokenType.semicolon,
            lexeme: ';',
            literal: null,
            line: 2,
            column: 15,
          ),
          Token(
            type: TokenType.rightBrace,
            lexeme: '}',
            literal: null,
            line: 3,
            column: 1,
          ),
          Token(
            type: TokenType.eof,
            literal: null,
            line: 4,
            column: 0,
          ),
        ],
      ),
    );
  });

  group('Errors', () {
    test('It should require a second pipe after the first one', () {
      final source = 'a | b;';
      final scanner = Scanner(source: source);
      final scanResult = scanner.scanTokens();

      expect(
        scanResult,
        const ScanResult(
          tokens: [
            Token(
              type: TokenType.identifier,
              lexeme: 'a',
              literal: null,
              line: 1,
              column: 2,
            ),
            Token(
              type: TokenType.identifier,
              lexeme: 'b',
              literal: null,
              line: 1,
              column: 6,
            ),
            Token(
              type: TokenType.semicolon,
              lexeme: ';',
              literal: null,
              line: 1,
              column: 7,
            ),
            Token(
              type: TokenType.eof,
              literal: null,
              line: 1,
              column: 7,
            ),
          ],
          errors: [
            ScannerError(
              line: 1,
              column: 4,
              message: 'Unexpected token "|"',
            ),
          ],
        ),
      );
    });

    test('It should require a second and after the first one', () {
      final source = 'a & b;';
      final scanner = Scanner(source: source);
      final scanResult = scanner.scanTokens();

      expect(
        scanResult,
        const ScanResult(
          tokens: [
            Token(
              type: TokenType.identifier,
              lexeme: 'a',
              literal: null,
              line: 1,
              column: 2,
            ),
            Token(
              type: TokenType.identifier,
              lexeme: 'b',
              literal: null,
              line: 1,
              column: 6,
            ),
            Token(
              type: TokenType.semicolon,
              lexeme: ';',
              literal: null,
              line: 1,
              column: 7,
            ),
            Token(
              type: TokenType.eof,
              literal: null,
              line: 1,
              column: 7,
            ),
          ],
          errors: [
            ScannerError(
              line: 1,
              column: 4,
              message: 'Unexpected token "&"',
            ),
          ],
        ),
      );
    });

    test('It should require a string to be terminated', () {
      final source = "var a = 'my string;";
      final scanner = Scanner(source: source);
      final scanResult = scanner.scanTokens();

      expect(
        scanResult,
        const ScanResult(
          tokens: [
            Token(
              type: TokenType.varKeyword,
              lexeme: 'var',
              line: 1,
              column: 4,
            ),
            Token(
              type: TokenType.identifier,
              lexeme: 'a',
              literal: null,
              line: 1,
              column: 6,
            ),
            Token(
              type: TokenType.equal,
              lexeme: '=',
              literal: null,
              line: 1,
              column: 8,
            ),
            Token(
              type: TokenType.eof,
              literal: null,
              line: 1,
              column: 20,
            ),
          ],
          errors: [
            ScannerError(
              line: 1,
              column: 20,
              message: 'Unterminated string.',
            ),
          ],
        ),
      );
    });
  });
}

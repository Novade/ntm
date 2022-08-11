import 'package:ntm/src/token.dart';
import 'package:ntm/src/token_type.dart';

class Scanner {
  Scanner({
    required this.source,
  });

  final String source;
  final List<Token> tokens = [];
  final List<TokenError> errors = [];

  var _start = 0;
  var _current = 0;

  /// The current line so the produced tokens know their location.
  var __line = 1;

  /// Comment
  int get _line => __line;
  set _line(int line) {
    __line = line;
    _startCurrentLine = _current + 1;
  }

  var _startCurrentLine = 0;

  /// The current column so the produced tokens know their location.
  int get _column => _current - _startCurrentLine + 1;

  bool get _isAtEnd {
    return _current >= source.length;
  }

  List<Token> scanTokens() {
    while (!_isAtEnd) {
      // We are at the beginning of the next lexeme.
      _start = _current;
      _scanToken();
    }

    tokens.add(
      Token(
        type: TokenType.eof,
        line: _line,
        column: _column,
      ),
    );
    return tokens;
  }

  void _scanToken() {
    final character = _advance();
    switch (character) {
      // Single character tokens.
      case '(':
        _addToken(TokenType.leftParenthesis);
        break;
      case ')':
        _addToken(TokenType.rightParenthesis);
        break;
      case '{':
        _addToken(TokenType.leftBrace);
        break;
      case '}':
        _addToken(TokenType.rightBrace);
        break;
      case ',':
        _addToken(TokenType.comma);
        break;
      case '.':
        _addToken(TokenType.dot);
        break;
      case '-':
        _addToken(TokenType.minus);
        break;
      case '+':
        _addToken(TokenType.plus);
        break;
      case ';':
        _addToken(TokenType.semicolon);
        break;
      case '*':
        _addToken(TokenType.star);
        break;
      case '!':
        _addToken(
          _match('=') ? TokenType.bangEqual : TokenType.bang,
        );
        break;
      case '=':
        _addToken(
          _match('=') ? TokenType.equalEqual : TokenType.equal,
        );
        break;
      case '<':
        _addToken(
          _match('=') ? TokenType.lessEqual : TokenType.less,
        );
        break;
      case '>':
        _addToken(
          _match('=') ? TokenType.greaterEqual : TokenType.greater,
        );
        break;
      // Comments.
      case '/':
        if (_match('/')) {
          // A comment goes until the end of the line.
          while (_peek() != '\n' && !_isAtEnd) {
            _advance();
          }
          // Comments are lexemes, but they aren’t meaningful, and the parser
          // doesn’t want to deal with them. So when we reach the end of the
          // comment, we don’t call `_addToken()`. When we loop back around to
          // start the next lexeme, start gets reset and the comment’s lexeme
          // disappears in a puff of smoke.
        } else {
          _addToken(TokenType.slash);
        }

        break;
      // "Useless" characters.
      case ' ':
      case '\r':
      case '\t':
        // Ignore whitespace.
        break;
      case '\n':
        _line++;
        break;
      // String literals.
      case "'":
        _string();
        break;
      default:
        if (_isDigit(character)) {
          _number();
        } else {
          _addError('Unexpected token "$character".');
        }
    }
  }

  String _advance() {
    return source[_current++];
  }

  /// It’s like a conditional [_advance]. We only consume the current character
  /// if it’s what we’re looking for.
  bool _match(String expected) {
    assert(expected.length == 1);
    if (_isAtEnd) {
      return false;
    }
    if (source[_current] != expected) {
      return false;
    }
    _current++;
    return true;
  }

  /// It’s sort of like [_advance], but doesn’t consume the character. This is
  /// called "lookahead". Since it only looks at the current unconsumed
  /// character, we have one character of lookahead. The smaller this number is,
  /// generally, the faster the scanner runs. The rules of the lexical grammar
  /// dictate how much lookahead we need. Fortunately, most languages in wide
  /// use peek only one or two characters ahead.
  String _peek() {
    if (_isAtEnd) {
      // TODO: What to return?
      return '';
    }
    return source[_current];
  }

  void _addToken(TokenType type, [Object? literal]) {
    final text = source.substring(_start, _current);
    tokens.add(
      Token(
        type: type,
        literal: literal,
        lexeme: text,
        line: _line,
        column: _column,
      ),
    );
  }

  void _addError(String message) {
    errors.add(
      TokenError(
        line: _line,
        column: _column,
        message: message,
      ),
    );
  }

  void _string() {
    while (_peek() != "'" && !_isAtEnd) {
      if (_peek() == '\n') {
        _addError('Unterminated string.');
        return;
      }
      _advance();
    }
    // The closing '
    if (_isAtEnd) {
      _addError('Unterminated string.');
      return;
    }
    _advance();
    // Trim the surrounding quotes.
    final value = source.substring(_start + 1, _current - 1);
    _addToken(TokenType.string, value);
  }

  bool _isDigit(String character) {
    assert(character.length == 1);
    return RegExp('[0-9]').hasMatch(character);
  }

  void _number() {
    while (_isDigit(_peek())) {
      _advance();
    }
    // Look for a fractional part.
    if (_peek() == '.' && _isDigit(_peekNext())) {
      // Consume the '.'.
      _advance();

      while (_isDigit(_peek())) {
        _advance();
      }
    }
    final text = source.substring(_start, _current);
    final value = double.tryParse(text);
    if (value == null) {
      _addError('Invalid number.');
      return;
    }
    _addToken(TokenType.number, value);
  }

  /// We could have made [_peek] take a parameter for the number of characters
  /// ahead to look instead of defining two functions, but that would allow
  /// arbitrarily far lookahead. Providing these two functions makes it clearer
  /// that our scanner looks ahead at most two characters.
  String _peekNext() {
    if (_current + 1 >= source.length) {
      return '';
    }
    return source[_current + 1];
  }
}

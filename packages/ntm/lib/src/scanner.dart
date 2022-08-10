import 'package:ntm/src/token.dart';
import 'package:ntm/src/token_type.dart';

class Scanner {
  Scanner({
    required this.source,
  });

  final String source;
  final List<Token> tokens = [];

  var _start = 0;
  final _current = 0;

  /// The current line so the produced tokens know their location.
  final _line = 1;

  /// The current column so the produced tokens know their location.
  final _column = 1;

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

  void _scanToken() {}
}

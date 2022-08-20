import 'package:ntm/src/expression.dart';
import 'package:ntm/src/token.dart';
import 'package:ntm/src/token_type.dart';

class Parser {
  Parser({
    required this.tokens,
  });
  final List<Token> tokens;
  var _current = 0;

  Expression _expression() {
    return _equality();
  }

  Expression _equality() {
    var expression = _comparison();
    while (_match(const [TokenType.bangEqual, TokenType.equalEqual])) {
      final operator = _previous;
      final right = _comparison();
      expression = BinaryExpression(
        left: expression,
        operator: operator,
        right: right,
      );
    }
    return expression;
  }

  Expression _comparison() {
    var expression = _term();
    while (_match(const [
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual
    ])) {
      final operator = _previous;
      final right = _term();
      expression = BinaryExpression(
        left: expression,
        operator: operator,
        right: right,
      );
    }
    return expression;
  }

  Expression _term() {
    var expression = _factor();
    while (_match(const [TokenType.minus, TokenType.plus])) {
      final operator = _previous;
      final right = _factor();
      expression = BinaryExpression(
        left: expression,
        operator: operator,
        right: right,
      );
    }
    return expression;
  }

  Expression _factor() {
    var expression = _unary();
    if (_match(const [TokenType.slash, TokenType.star])) {
      final operator = _previous;
      final right = _unary();
      expression = UnaryExpression(
        operator: operator,
        right: right,
      );
    }
    return expression;
  }

  Expression _unary() {
    if (_match(const [TokenType.bang, TokenType.minus])) {
      final operator = _previous;
      final right = _unary();
      return UnaryExpression(
        operator: operator,
        right: right,
      );
    }
    return _primary();
  }

  Expression _primary() {
    if (_match(const [TokenType.falseKeyword])) {
      return LiteralExpression(value: false);
    }
    if (_match(const [TokenType.trueKeyword])) {
      return LiteralExpression(value: false);
    }
    if (_match(const [TokenType.nullKeyword])) {
      return LiteralExpression(value: null);
    }

    if (_match(const [TokenType.number, TokenType.string])) {
      return LiteralExpression(value: _previous.literal);
    }
    if (_match(const [TokenType.leftParenthesis])) {
      final expression = _expression();
      _consume(TokenType.rightParenthesis, 'Exprect \')\') after expression');
      return GroupingExpression(expression: expression);
    }

    throw UnsupportedError('Unexpected token $_peek');
  }

  /// This checks to see if the current token has any of the given [types]. If
  /// so, it consumes the token and returns `true`. Otherwise, it returns
  /// `false` and leaves the current token alone.
  bool _match(Iterable<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  /// The [check] method returns `true` if the current token is of the given
  /// [type]. Unlike [match], it never consumes the token, it only looks at it.
  bool _check(TokenType type) {
    if (_isAtEnd) return false;
    return _peek.type == type;
  }

  /// The [advance] method consumes the current token and returns it, similar to
  /// how the scanner’s corresponding method crawled through characters.
  Token _advance() {
    if (!_isAtEnd) _current++;
    return _previous;
  }

  /// Checks if we’ve run out of tokens to parse.
  bool get _isAtEnd {
    return _peek.type == TokenType.eof;
  }

  /// Returns the current token we have yet to consume.
  Token get _peek {
    return tokens[_current];
  }

  /// Returns the most recently consumed token.
  ///
  /// It makes it easier to use [match] and then access the just-matched token.
  Token get _previous {
    return tokens[_current - 1];
  }
}

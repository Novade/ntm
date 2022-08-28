import 'package:ntm/src/descriptive_error.dart';
import 'package:ntm/src/expression.dart';
import 'package:ntm/src/statement.dart';
import 'package:ntm/src/token.dart';
import 'package:ntm/src/token_type.dart';

/// {@template ntm.parser}
/// Has 2 jobs
/// - Given a valid sequence of [tokens], produce a corresponding syntax tree.
/// - Given an *invalid* sequence of [tokens], detect any errors and tell the
///   user about their mistakes.
/// {@endtemplate}
class Parser {
  /// {@macro ntm.parser}
  Parser({
    required this.tokens,
  });
  final List<Token> tokens;
  final List<ParseError> _errors = [];

  var _current = 0;

  ParseResult parse() {
    _errors.clear();
    final statements = <Statement>[];
    while (!_isAtEnd) {
      final statement = _declaration();
      if (statement != null) {
        statements.add(statement);
      }
    }

    return ParseResult(
      statements: statements,
      errors: _errors,
    );
  }

  /// ```
  /// expression -> assignment ;
  /// ```
  Expression _expression() {
    return _assignment();
  }

  Statement? _declaration() {
    try {
      if (_match(const [TokenType.varKeyword])) return _varDeclaration();
      return _statement();
    } on ParseError {
      _synchronize();
    }
    return null;
  }

  /// ```
  /// statement -> expressionStatement
  ///            | ifStatement
  ///            | printStatement
  ///            | block ;
  /// ```
  Statement _statement() {
    if (_match(const [TokenType.ifKeyword])) return _ifStatement();
    if (_match(const [TokenType.printKeyword])) return _printStatement();
    if (_match(const [TokenType.leftBrace])) {
      return BlockStatement(statements: _block());
    }
    return _expressionStatement();
  }

  Statement _expressionStatement() {
    final expression = _expression();
    _consume(TokenType.semicolon, 'Expect ";" after expression.');
    return ExpressionStatement(expression);
  }

  /// ```
  /// ifStatement -> 'if' '(' expression ')' statement
  ///              ( 'else' statement )? ;
  /// ```
  Statement _ifStatement() {
    _consume(TokenType.leftParenthesis, 'Expect "(" after "if".');
    final condition = _expression();
    _consume(TokenType.rightParenthesis, 'Expect ")" after if condition.');
    final thenBranch = _statement();
    late final Statement? elseBranch;
    if (_match(const [TokenType.elseKeyword])) {
      elseBranch = _statement();
    } else {
      elseBranch = null;
    }
    return IfStatement(
      condition: condition,
      thenBranch: thenBranch,
      elseBranch: elseBranch,
    );
  }

  /// ```
  /// block -> "{" declaration* "}"
  /// ```
  List<Statement> _block() {
    final statements = <Statement>[];
    while (!_check(TokenType.rightBrace) && !_isAtEnd) {
      final declaration = _declaration();
      if (declaration != null) {
        statements.add(declaration);
      }
    }
    _consume(TokenType.rightBrace, 'Expect a "}" after block.');
    return statements;
  }

  /// ```
  /// assignment -> IDENTIFIER "=" assignment
  ///             | logical_or ;
  /// ```
  Expression _assignment() {
    final expression = _or();
    if (_match(const [TokenType.equal])) {
      final equals = _previous;
      final value = _assignment();

      if (expression is VariableExpression) {
        return AssignExpression(
          name: expression.name,
          value: value,
        );
      }

      _error(equals, 'Invalid assignment target.');
    }
    return expression;
  }

  /// ```
  /// logical_or -> logical_and ( 'or' logical_and )* ;
  /// ```
  Expression _or() {
    var expression = _and();

    while (_match(const [TokenType.pipePipe])) {
      final operator = _previous;
      final right = _and();
      expression = LogicalExpression(
        left: expression,
        operator: operator,
        right: right,
      );
    }
    return expression;
  }

  /// ```
  /// logical_and -> equality ( 'and' equality )* ;
  /// ```
  Expression _and() {
    var expression = _equality();
    while (_match(const [TokenType.andAnd])) {
      final operator = _previous;
      final right = _equality();
      expression = LogicalExpression(
        left: expression,
        operator: operator,
        right: right,
      );
    }
    return expression;
  }

  /// Since we already matched and consumed the `print` token itself, we don’t
  /// need to do that here. We parse the subsequent expression, consume the
  /// terminating semicolon, and emit the syntax tree.
  Statement _printStatement() {
    final value = _expression();
    _consume(TokenType.semicolon, 'Expect ";" after value.');
    return PrintStatement(value);
  }

  Statement _varDeclaration() {
    final name = _consume(TokenType.identifier, 'Expect a variable name.');

    final Expression? initializer;
    if (_match(const [TokenType.equal])) {
      initializer = _expression();
    } else {
      initializer = null;
    }
    _consume(TokenType.semicolon, 'Expect ";" after a variable declaration.');
    return VarStatement(
      name: name,
      initializer: initializer,
    );
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
      return LiteralExpression(value: true);
    }
    if (_match(const [TokenType.nullKeyword])) {
      return LiteralExpression(value: null);
    }

    if (_match(const [TokenType.number, TokenType.string])) {
      return LiteralExpression(value: _previous.literal);
    }
    if (_match(const [TokenType.identifier])) {
      return VariableExpression(_previous);
    }
    if (_match(const [TokenType.leftParenthesis])) {
      final expression = _expression();
      _consume(TokenType.rightParenthesis, 'Expect \')\') after expression');
      return GroupingExpression(expression: expression);
    }

    throw _error(_peek, 'Expect expression.');
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

  /// It’s similar to [match] in that it checks to see if the next token is of
  /// the expected type. If so, it consumes the token and everything is groovy.
  /// If some other token is there, then we’ve hit an error.
  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw _error(_peek, message);
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

  ParseError _error(Token token, String message) {
    final error = ParseError(token: token, message: message);
    _errors.add(error);
    return error;
  }

  /// Discards tokens until it thinks it has found a statement boundary.
  void _synchronize() {
    _advance();
    while (!_isAtEnd) {
      if (_previous.type == TokenType.semicolon) return;
      switch (_peek.type) {
        case TokenType.classKeyword:
        case TokenType.funKeyword:
        case TokenType.varKeyword:
        case TokenType.forKeyword:
        case TokenType.whileKeyword:
        case TokenType.ifKeyword:
        case TokenType.printKeyword:
          return;
        default:
          _advance();
      }
    }
  }
}

class ParseResult {
  const ParseResult({
    this.statements = const [],
    this.errors = const [],
  });

  final List<Statement> statements;
  final List<ParseError> errors;
}

class ParseError extends DescriptiveError {
  const ParseError({
    required this.token,
    required this.message,
  });

  final Token token;
  final String message;

  @override
  String describe() {
    final String where;
    if (token.type == TokenType.eof) {
      where = 'at end';
    } else {
      where = 'at "${token.lexeme}"';
    }
    return '[line ${token.line}:${token.column}] Error $where: $message';
  }
}

import 'package:ntm/src/describable_error.dart';
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

  /// ```
  /// declaration -> classDeclaration
  ///              | functionDeclaration
  ///              | varDeclaration
  ///              | statement ;
  /// ```
  Statement? _declaration() {
    try {
      if (_match(const [TokenType.classKeyword])) {
        return _classDeclaration();
      }
      if (_match(const [TokenType.funKeyword])) {
        return _function(_FunctionType.function);
      }
      if (_match(const [TokenType.varKeyword])) return _varDeclaration();
      return _statement();
    } on ParseError {
      _synchronize();
    }
    return null;
  }

  /// ```
  /// classDeclaration -> 'class' IDENTIFIER '{' function* '}; ;
  /// ```
  Statement _classDeclaration() {
    final name = _consume(TokenType.identifier, 'Expect class name.');
    _consume(TokenType.leftBrace, 'Expect "{" before class body.');

    final methods = <FunctionStatement>[];
    while (!_check(TokenType.rightBrace) && !_isAtEnd) {
      methods.add(_function(_FunctionType.method));
    }

    _consume(TokenType.rightBrace, 'Expect "}" after class body.');
    return ClassStatement(name: name, methods: methods);
  }

  /// ```
  /// statement -> expressionStatement
  ///            | forStatement
  ///            | ifStatement
  ///            | printStatement
  ///            | returnStatement
  ///            | whileStatement
  ///            | block ;
  /// ```
  Statement _statement() {
    if (_match(const [TokenType.forKeyword])) return _forStatement();
    if (_match(const [TokenType.ifKeyword])) return _ifStatement();
    if (_match(const [TokenType.printKeyword])) return _printStatement();
    if (_match(const [TokenType.returnKeyword])) return _returnStatement();
    if (_match(const [TokenType.whileKeyword])) return _whileStatement();
    if (_match(const [TokenType.leftBrace])) {
      return BlockStatement(statements: _block());
    }
    return _expressionStatement();
  }

  /// ```
  /// forStatement -> 'for' '(' (varDeclaration | expressionStatement | ';' )
  ///                 expression? ';'
  ///                 expression? ')' statement ;
  /// ```
  Statement _forStatement() {
    _consume(TokenType.leftParenthesis, 'Expect "(" after "for".');

    // If the token following the `(` is a semicolon then the initializer has been
    // omitted. Otherwise, we check for a `var` keyword to see if it’s a variable
    // declaration. If neither of those matched, it must be an expression. We
    // parse that and wrap it in an expression statement so that the initializer
    // is always of type `Statement`.
    late final Statement? initializer;
    if (_match(const [TokenType.semicolon])) {
      initializer = null;
    } else if (_match(const [TokenType.varKeyword])) {
      initializer = _varDeclaration();
    } else {
      initializer = _expressionStatement();
    }

    // Again, we look for a semicolon to see if the clause has been omitted.
    Expression? condition;
    if (!_check(TokenType.semicolon)) {
      condition = _expression();
    }
    _consume(TokenType.semicolon, 'Expect ";" after loop condition.');

    // It’s similar to the condition clause except this one is terminated by the
    // closing parenthesis.
    late final Expression? increment;
    if (!_check(TokenType.rightParenthesis)) {
      increment = _expression();
    } else {
      increment = null;
    }
    _consume(TokenType.rightParenthesis, 'Expect ")" after for clauses.');

    // All that remains is the body.
    var body = _statement();

    // We’ve parsed all of the various pieces of the for loop and the resulting
    // AST nodes are sitting in a handful of dart local variables. This is where
    // the desugaring comes in. We take those and use them to synthesize syntax
    // tree nodes that express the semantics of the for loop.
    //
    // The code is a little simpler if we work backward, so we start with the
    // increment clause.
    if (increment != null) {
      // The increment, if there is one, executes after the body in each
      // iteration of the loop. We do that by replacing the body with a little
      // block that contains the original body followed by an expression
      // statement that evaluates the increment.
      body = BlockStatement(
        statements: [
          body,
          ExpressionStatement(increment),
        ],
      );
    }

    // Next, we take the condition and the body and build the loop using a
    // primitive `while` loop. If the condition is omitted, we jam in `true` to
    // make an infinite loop.
    condition ??= LiteralExpression(value: true);
    body = WhileStatement(
      condition: condition,
      body: body,
    );

    if (initializer != null) {
      // Finally, if there is an initializer, it runs once before the entire
      // loop. We do that by, again, replacing the whole statement with a block
      // that runs the initializer and then executes the loop.
      body = BlockStatement(
        statements: [initializer, body],
      );
    }

    return body;
  }

  Statement _expressionStatement() {
    final expression = _expression();
    _consume(TokenType.semicolon, 'Expect ";" after expression.');
    return ExpressionStatement(expression);
  }

  /// ```
  /// functionDeclaration -> 'fun' function ;
  /// function -> IDENTIFIER '(' parameters? ')' block ;
  /// ```
  FunctionStatement _function(_FunctionType functionType) {
    final name = _consume(
      TokenType.identifier,
      'Expect ${functionType.name} name.',
    );

    // This is like the code for handling arguments in a call, except not split
    // out into a helper method. The outer `if` statement handles the zero
    // parameter case, and the inner `while` loop parses parameters as long as
    // we find commas to separate them. The result is the list of tokens for
    // each parameter’s name.

    _consume(TokenType.leftParenthesis,
        'Expect "(" after ${functionType.name} name.');
    final parameters = <Token>[];
    if (!_check(TokenType.rightParenthesis)) {
      do {
        parameters.add(_consume(
          TokenType.identifier,
          'Expect parameter name.',
        ));
      } while (_match(const [TokenType.comma]));
    }
    _consume(TokenType.rightParenthesis, 'Expect ")" after parameters.');

    // Note that we consume the `{` at the beginning of the body here before
    // calling [_block]. That’s because [_block] assumes the brace token has
    // already been matched. Consuming it here lets us report a more precise
    // error message if the `{` isn’t found since we know it’s in the context of
    // a function declaration.
    _consume(
      TokenType.leftBrace,
      'Expect "{" before ${functionType.name} body.',
    );
    final body = _block();
    return FunctionStatement(
      name: name,
      params: parameters,
      body: body,
    );
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
  /// assignment -> ( call '.' )? IDENTIFIER "=" assignment
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
      } else if (expression is GetExpression) {
        return SetExpression(
          object: expression.object,
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

  /// ```
  /// returnStatement -> 'return' expression? ';' ;
  /// ```
  Statement _returnStatement() {
    final keyword = _previous;

    // After snagging the previously consumed `return` keyword, we look for a
    // value expression. Since many different tokens can potentially start an
    // expression, it’s hard to tell if a return value is present. Instead, we
    // check if it’s absent. Since a semicolon can’t begin an expression, if the
    // next token is that, we know there must not be a value.
    late final Expression? value;
    if (!_check(TokenType.semicolon)) {
      value = _expression();
    } else {
      value = null;
    }
    _consume(TokenType.semicolon, 'Expect ";" after return value.');
    return ReturnStatement(
      keyword: keyword,
      value: value,
    );
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

  /// ```
  /// whileStatement -> 'while' '(' expression ')' statement ;
  /// ```
  Statement _whileStatement() {
    _consume(TokenType.leftParenthesis, 'Expect "(" after "while".');
    final condition = _expression();
    _consume(TokenType.rightParenthesis, 'Expect ")" after condition.');
    final body = _statement();

    return WhileStatement(
      condition: condition,
      body: body,
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
      expression = BinaryExpression(
        left: expression,
        operator: operator,
        right: right,
      );
    }
    return expression;
  }

  /// ```
  /// unary -> ( '!' | '-' ) unary | call ;
  /// ```
  Expression _unary() {
    if (_match(const [TokenType.bang, TokenType.minus])) {
      final operator = _previous;
      final right = _unary();
      return UnaryExpression(
        operator: operator,
        right: right,
      );
    }
    return _call();
  }

  /// This is more or less the `arguments` grammar rule translated to code,
  /// except that we also handle the zero-argument case. We check for that case
  /// first by seeing if the next token is `)`. If it is, we don’t try to parse
  /// any arguments.
  ///
  /// Otherwise, we parse an expression, then look for a comma indicating that
  /// there is another argument after that. We keep doing that as long as we
  /// find commas after each expression. When we don’t find a comma, then the
  /// argument list must be done and we consume the expected closing
  /// parenthesis. Finally, we wrap the callee and those arguments up into a
  /// call AST node.
  Expression _finishCall(Expression callee) {
    final arguments = <Expression>[];
    if (!_check(TokenType.rightParenthesis)) {
      do {
        arguments.add(_expression());
      } while (_match(const [TokenType.comma]));
    }

    final closingParenthesis = _consume(
      TokenType.rightParenthesis,
      'Expect ")" after arguments.',
    );

    return CallExpression(
      callee: callee,
      closingParenthesis: closingParenthesis,
      arguments: arguments,
    );
  }

  /// ```
  /// call -> primary ( '(' arguments? ')' | '.' IDENTIFIER )* ;
  /// arguments -> expression ( ',', expression )* ;
  /// ```
  Expression _call() {
    var expression = _primary();
    while (true) {
      if (_match(const [TokenType.leftParenthesis])) {
        expression = _finishCall(expression);
      } else if (_match(const [TokenType.dot])) {
        final name = _consume(
          TokenType.identifier,
          'Expect property name after ".".',
        );
        expression = GetExpression(object: expression, name: name);
      } else {
        break;
      }
    }
    return expression;
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

class ParseError extends DescribableError {
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

enum _FunctionType {
  function,
  method,
}

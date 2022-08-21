import 'dart:io';

import 'package:ntm/src/token.dart';
import 'package:ntm/src/token_type.dart';

class ErrorHandler {
  ErrorHandler();

  final errors = <ErrorBase>[];

  void report({
    required int line,
    required int column,
    required String where,
    required String message,
  }) {
    stderr.writeln('[line $line:$column] Error $where: $message');
  }

  void error(Token token, String message) {
    if (token.type == TokenType.eof) {
      report(
        line: token.line,
        column: token.column,
        where: 'at end',
        message: message,
      );
    } else {
      report(
        line: token.line,
        column: token.column,
        where: 'at "${token.lexeme}"',
        message: message,
      );
    }
  }
}

class ErrorBase {
  const ErrorBase({
    required this.line,
    required this.column,
  });

  final int line;
  final int column;
}

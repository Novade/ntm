import 'dart:io';

import 'package:ntm/src/interpreter.dart';
import 'package:ntm/src/parser.dart';
import 'package:ntm/src/resolver.dart';
import 'package:ntm/src/scanner.dart';

class Ntm {
  Ntm();

  final interpreter = Interpreter();

  void run(String script) {
    interpreter.errors.clear();
    final scanner = Scanner(source: script);
    final scanResult = scanner.scanTokens();
    if (scanResult.errors.isNotEmpty) {
      for (final error in scanResult.errors) {
        stderr.writeln(error.describe());
      }
      return;
    }

    final parser = Parser(tokens: scanResult.tokens);
    final parseResult = parser.parse();
    if (parseResult.errors.isNotEmpty) {
      for (final error in parseResult.errors) {
        stderr.writeln(error.describe());
      }
      return;
    }

    final resolver = Resolver(interpreter);
    final resolverErrors = resolver.resolve(parseResult.statements);
    if (resolverErrors.isNotEmpty) {
      for (final error in resolverErrors) {
        stderr.writeln(error.describe());
      }
      return;
    }

    interpreter.interpret(parseResult.statements);
    if (interpreter.errors.isNotEmpty) {
      for (final error in interpreter.errors) {
        stderr.writeln(error.describe());
      }
    }
  }
}

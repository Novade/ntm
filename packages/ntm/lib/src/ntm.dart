import 'dart:io';

import 'package:ntm/src/interpreter.dart';
import 'package:ntm/src/parser.dart';
import 'package:ntm/src/scanner.dart';

class Ntm {
  Ntm();

  final interpreter = Interpreter();

  Scanner? scanner;

  Parser? parser;

  void run(String script) {
    interpreter.errors.clear();
    scanner = Scanner(source: script)..scanTokens();
    if (scanner!.errors.isNotEmpty) {
      for (final error in scanner!.errors) {
        stderr.writeln(error.describe());
      }
      return;
    }
    parser = Parser(tokens: scanner!.tokens);

    final expression = parser!.parse();

    if (parser!.errors.isNotEmpty) {
      for (final error in parser!.errors) {
        stderr.writeln(error.describe());
      }
      return;
    }
    interpreter.interpret(expression!);

    if (interpreter.errors.isNotEmpty) {
      for (final error in interpreter.errors) {
        stderr.writeln(error.describe());
      }
    }
  }
}

import 'dart:io';

import 'package:ntm_cli/ntm_cli.dart';

void main(List<String> arguments) {
  exitCode = 0; // Presume success.

  if (arguments.length > 1) {
    exitCode = 2;
    stderr.writeln('Usage: ntm [script]');
  } else if (arguments.length == 1) {
    runFile(arguments.first);
  } else {
    runPrompt();
  }
}

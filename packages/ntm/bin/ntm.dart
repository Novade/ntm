import 'dart:io';

import 'package:ntm/ntm.dart';

final _ntm = Ntm();

void main(List<String> arguments) {
  exitCode = 0; // Presume success.
  return _runFile('test/test.ntm');

  if (arguments.length > 1) {
    exitCode = 2;
    stderr.writeln('Usage: ntm [script]');
  } else if (arguments.length == 1) {
    _runFile(arguments.first);
    if (_hadError) {
      exitCode = 2;
    }
  } else {
    _runPrompt();
  }
}

void _runFile(String path) {
  final file = File(path);
  _run(file.readAsStringSync());
}

void _runPrompt() {
  while (true) {
    stdout.write('[ntm] > ');
    final line = stdin.readLineSync();
    if (line == null) {
      break;
    }
    _run(line);
    _hadError = false;
  }
}

void _run(String script) {
  _ntm.run(script);
}

void _error(int line, String message) {
  report(line: line, where: '', message: message);
}

var _hadError = false;

void report({
  required int line,
  required String where,
  required String message,
}) {
  stderr.writeln('[line $line] Error $where: $message');
  _hadError = true;
}

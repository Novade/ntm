import 'dart:io';

import 'package:ntm/ntm.dart';

final _ntm = Ntm();

/// Runs a dart file
void runFile(String path) {
  final file = File(path);
  _run(file.readAsStringSync());
}

/// Runs the interactive console.
void runPrompt() {
  while (true) {
    stdout.write('[ntm] > ');
    final line = stdin.readLineSync();
    if (line == null) {
      break;
    }
    _run(line);
  }
}

void _run(String script) {
  _ntm.run(script);
}

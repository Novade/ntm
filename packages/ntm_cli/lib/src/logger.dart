import 'dart:io';

import 'package:ntm_core/ntm_core.dart';

/// A logger that logs to the console.
class Logger extends NtmLogger {
  /// A logger that logs to the console.
  const Logger();

  @override
  void log(NtmLog log) {
    if (log.isError) {
      stderr.writeln(log.log);
    } else {
      stdout.writeln(log.log);
    }
  }
}

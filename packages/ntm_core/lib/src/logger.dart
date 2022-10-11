import 'package:ntm_core/ntm_core.dart';

/// A log that can be given to the [NtmLogger].
abstract class NtmLog {
  /// A log that can be given to the [NtmLogger].
  const NtmLog();

  /// The log message.
  String get log;

  /// Whether the log is an error.
  bool get isError;
}

/// A logger that accepts [NtmLog]s.
abstract class NtmLogger {
  /// A logger that accepts [NtmLog]s.
  const NtmLogger();

  /// Logs the given [log].
  void log(NtmLog log);
}

/// A log that logs the string representation of the given [object].
class ObjectLog extends NtmLog {
  /// A log that logs the string representation of the given [object].
  const ObjectLog(this.object);

  /// The object to log.
  final Object? object;

  @override
  String get log => object.toString();

  @override
  bool get isError => false;
}

/// A log that accept a [Describable] and logs its description.
class DescribableLog extends NtmLog {
  /// A log that accept a [Describable] and logs its description.
  const DescribableLog(this.describable);

  /// The describable to log.
  final Describable describable;

  @override
  bool get isError => describable is DescribableError;

  @override
  String get log => describable.describe();
}

/// A logger that aggregates the logs.
class AccumulatorLogger extends NtmLogger {
  /// All the logs the logger has received.
  final List<NtmLog> ntmLogs = [];

  @override
  void log(NtmLog log) {
    ntmLogs.add(log);
  }

  /// The logs from the received [NtmLog]s.
  Iterable<String> get logs => ntmLogs.map((log) => log.log);
}

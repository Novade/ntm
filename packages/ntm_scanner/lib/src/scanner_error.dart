import 'package:equatable/equatable.dart';
import 'package:ntm_core/ntm_core.dart';

/// An error that occurred during the scan of a ntm text file.
class ScannerError extends DescribableError with EquatableMixin {
  /// An error that occurred during the scan of a ntm text file.
  const ScannerError({
    required this.line,
    required this.column,
    required this.message,
  });

  /// The line of the error.
  final int line;

  /// The column of the error.
  final int column;

  /// The error message.
  final String message;

  @override
  String describe() {
    return '[$line:$column]: $message';
  }

  @override
  String toString() {
    return '''
ScannerError(
  line: $line,
  column: $column,
  message: $message,
)''';
  }

  @override
  List<Object?> get props => [line, column, message];
}

import 'package:ntm_core/ntm_core.dart';

class ScannerError extends DescribableError {
  const ScannerError({
    required this.line,
    required this.column,
    required this.message,
  });
  final int line;
  final int column;
  final String message;

  @override
  String describe() {
    return '[$line:$column]: $message';
  }
}

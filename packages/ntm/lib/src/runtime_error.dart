import 'package:ntm/src/describable_error.dart';
import 'package:ntm/src/token.dart';

class RuntimeError implements DescribableError {
  const RuntimeError({
    required this.token,
    required this.message,
  });

  final Token token;
  final String message;

  @override
  String describe() {
    return '[${token.line}:${token.column}] $message';
  }
}

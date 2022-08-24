import 'package:ntm/src/descriptive_error.dart';
import 'package:ntm/src/token.dart';

class RuntimeError implements DescriptiveError {
  const RuntimeError({
    required this.token,
    required this.message,
  });

  final Token token;
  final String message;

  @override
  String describe() {
    return '$message\n[${token.line}:${token.column}]';
  }
}

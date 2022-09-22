import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_core/ntm_core.dart';

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

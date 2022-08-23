import 'package:ntm/src/token.dart';

class RuntimeError implements Exception {
  const RuntimeError({
    required this.token,
    required this.message,
  });

  final Token token;
  final String message;
}

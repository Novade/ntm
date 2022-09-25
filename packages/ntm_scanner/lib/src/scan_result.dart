import 'package:equatable/equatable.dart';
import 'package:ntm_core/ntm_core.dart';

import 'scanner_error.dart';

/// The result returned by the `Scanner`.
///
/// Contains the list of [tokens] and a list of [errors].
class ScanResult with EquatableMixin {
  /// The result returned by the `Scanner`.
  ///
  /// Contains the list of [tokens] and a list of [errors].
  const ScanResult({
    this.tokens = const [],
    this.errors = const [],
  });

  /// The scanned tokens.
  final List<Token> tokens;

  /// The scanner errors.
  final List<ScannerError> errors;

  @override
  List<Object?> get props => [tokens, errors];
}

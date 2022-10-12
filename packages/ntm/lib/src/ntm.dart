import 'package:ntm_core/ntm_core.dart';
import 'package:ntm_interpreter/ntm_interpreter.dart';
import 'package:ntm_parser/ntm_parser.dart';
import 'package:ntm_scanner/ntm_scanner.dart';

/// {@template ntm}
/// A class able to parse and interpret a ntm text script.
///
/// {@endtemplate}
class Ntm {
  /// {@template ntm}
  Ntm({
    this.logger,
  });

  final NtmLogger? logger;

  late final interpreter = Interpreter(logger: logger);

  /// Runs the given ntm [script].
  void run(String script) {
    final scanner = Scanner(source: script);
    final scanResult = scanner.scanTokens();
    if (logger != null && scanResult.errors.isNotEmpty) {
      for (final error in scanResult.errors) {
        logger!.log(DescribableLog(error));
      }
      return;
    }

    final parser = Parser(tokens: scanResult.tokens);
    final parseResult = parser.parse();
    if (logger != null && parseResult.errors.isNotEmpty) {
      for (final error in parseResult.errors) {
        logger!.log(DescribableLog(error));
      }
      return;
    }

    final resolver = Resolver(interpreter);
    final resolverErrors = resolver.resolve(parseResult.statements);
    if (logger != null && resolverErrors.isNotEmpty) {
      for (final error in resolverErrors) {
        logger!.log(DescribableLog(error));
      }
      return;
    }

    interpreter.interpret(parseResult.statements);
  }
}

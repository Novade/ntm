import 'package:ntm_scanner/ntm_scanner.dart';

void main() {
  final source = r"print 'Hello World';";
  final scanner = Scanner(source: source);
  final scanResult = scanner.scanTokens();
  print(scanResult);
}

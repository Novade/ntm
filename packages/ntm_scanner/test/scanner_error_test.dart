import 'package:ntm_scanner/ntm_scanner.dart';
import 'package:test/test.dart';

void main() {
  test('It should display the error message', () {
    final error = ScannerError(
      line: 3,
      column: 4,
      message: 'My error message.',
    );
    expect(error.describe(), '[3:4]: My error message.');
  });
}

import 'dart:io';

void main(List<String> args) {
  if (args.length != 1) {
    exitCode = 2;
    stderr.writeln('Usage: generate_ast <output file>');
  }
  final outputFile = args.first;
  _defineAst(
    outputFile: outputFile,
    types: [],
  );
}

void _defineAst({
  required String outputFile,
  required List<String> types,
}) {
  final stringBuffer = StringBuffer();

  stringBuffer.write('''
abstract class Expression {
  const Expression();
}
''');

  File(outputFile)
    ..createSync()
    ..writeAsString(stringBuffer.toString());
}

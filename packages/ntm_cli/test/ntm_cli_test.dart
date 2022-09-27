import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  test('It should run the ntm file', () async {
    final process = await TestProcess.start(
      'dart',
      const ['run', 'ntm_cli', 'test/test.ntm'],
    );
    final stdoutList = <String>[];
    while (await process.stdout.hasNext) {
      stdoutList.add(await process.stdout.next);
    }
    expect(stdoutList, orderedEquals(const ['Hello World']));
  });
}

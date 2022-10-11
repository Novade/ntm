import 'package:ntm_core/ntm_core.dart';
import 'package:test/test.dart';

class _Describable extends Describable {
  const _Describable();

  @override
  String describe() => 'description';
}

class _DescribableError extends DescribableError {
  const _DescribableError();

  @override
  String describe() => 'error';
}

void main() {
  test(
    'A describable log should not be considered as an error by default',
    () {
      const describable = _Describable();
      final log = DescribableLog(describable);
      expect(log.isError, false);
      expect(log.log, 'description');
    },
  );
  test(
    'A describable log with an error should be considered as an error',
    () {
      const error = _DescribableError();
      final log = DescribableLog(error);
      expect(log.isError, true);
      expect(log.log, 'error');
    },
  );
}

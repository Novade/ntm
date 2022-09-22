import 'describable.dart';

abstract class DescribableError implements Exception, Describable {
  const DescribableError();
}

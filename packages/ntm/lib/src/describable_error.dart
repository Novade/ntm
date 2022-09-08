import 'package:ntm/src/describable.dart';

abstract class DescribableError implements Exception, Describable {
  const DescribableError();
}

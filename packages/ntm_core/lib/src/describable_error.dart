import 'describable.dart';

/// An error that has a describable message the user can read.
abstract class DescribableError implements Exception, Describable {
  /// An error that has a describable message the user can read.
  const DescribableError();
}

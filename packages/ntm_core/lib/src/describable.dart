/// {@template ntm.core.describable}
/// A describable object.
///
/// [describe] can be call to get a meaningful message for the user.
/// {@endtemplate}
abstract class Describable {
  /// {@macro ntm.core.describable}
  const Describable();

  /// Returns a meaningful message that can be read by the user.
  String describe();
}

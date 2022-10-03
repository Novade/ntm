import 'package:ntm_core/ntm_core.dart';

import 'ntm_class.dart';
import 'runtime_error.dart';

/// A class instance in the Ntm language.
class NtmInstance implements Describable {
  /// A class instance in the Ntm language.
  NtmInstance(this.ntmClass);

  /// The class of the instance.
  final NtmClass ntmClass;
  final _fields = <String, Object?>{};

  /// Gets the value of the field.
  Object? get(Token name) {
    // When looking up a property on an instance, if we don’t find a matching
    // field, we look for a method with that name on the instance’s class. If
    // found, we return that. This is where the distinction between “field” and
    // “property” becomes meaningful. When accessing a property, you might get a
    // field—a bit of state stored on the instance—or you could hit a method
    // defined on the instance’s class.
    //
    // Looking for a field first implies that fields shadow methods, a subtle
    // but important semantic point.

    if (ntmClass.hasField(name.lexeme)) {
      if (_fields.containsKey(name.lexeme)) {
        return _fields[name.lexeme];
      } else {
        throw RuntimeError(
          token: name,
          message: 'The field "${name.lexeme}" is not initialized.',
        );
      }
    }

    // TODO: Disallow method shadowing ?
    final method = ntmClass.findMethod(name.lexeme);
    if (method != null) return method.bind(this);

    throw RuntimeError(
      token: name,
      message: 'Undefined property "${name.lexeme}".',
    );
  }

  /// Sets the field of the instance.
  void set(Token name, Object? value) {
    _fields[name.lexeme] = value;
  }

  @override
  String describe() {
    return '${ntmClass.name} instance';
  }
}

import 'package:ntm/src/describable.dart';
import 'package:ntm/src/ntm_class.dart';
import 'package:ntm/src/runtime_error.dart';
import 'package:ntm/src/token.dart';

class NtmInstance implements Describable {
  NtmInstance(this.ntmClass);

  final NtmClass ntmClass;
  final _fields = <String, Object?>{};
  Object? get(Token name) {
    if (_fields.containsKey(name.lexeme)) {
      return _fields[name.lexeme];
    }

    // TODO: Add fields to class.
    throw RuntimeError(
      token: name,
      message: 'Undefined property "${name.lexeme}".',
    );
  }

  void set(Token name, Object? value) {
    _fields[name.lexeme] = value;
  }

  @override
  String describe() {
    return '${ntmClass.name} instance';
  }
}

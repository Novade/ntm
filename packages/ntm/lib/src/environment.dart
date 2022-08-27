import 'package:ntm/src/runtime_error.dart';
import 'package:ntm/src/token.dart';

class Environment {
  final _values = <String, Object?>{};

  void define(String name, Object? value) {
    _values[name] = value;
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }
    throw RuntimeError(
      token: name,
      message: 'Undefined variable "${name.lexeme}".',
    );
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }
    throw RuntimeError(
      token: name,
      message: 'Undefined variable "${name.lexeme}".',
    );
  }
}

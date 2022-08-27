import 'package:ntm/src/runtime_error.dart';
import 'package:ntm/src/token.dart';

/// Default values given to variables that are declared but not defined.
class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

class Environment {
  Environment({
    this.enclosing,
  });

  /// The enclosing environment.
  final Environment? enclosing;

  final _values = <String, Object?>{};

  /// Declare a variable and directly assign a value to it.
  void define(String name, Object? value) {
    _values[name] = value;
  }

  /// Declare a variable without assigning a value to it.
  void declare(String name) {
    _values[name] = _undefined;
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      final value = _values[name.lexeme];
      if (value == _undefined) {
        throw RuntimeError(
          token: name,
          message:
              'The variable "${name.lexeme}" was declared but never assigned.',
        );
      }
      return value;
    }

    if (enclosing != null) return enclosing!.get(name);

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

    if (enclosing != null) return enclosing!.assign(name, value);

    throw RuntimeError(
      token: name,
      message: 'Undefined variable "${name.lexeme}".',
    );
  }
}

import 'package:ntm_core/ntm_core.dart';

import 'runtime_error.dart';

/// Default values given to variables that are declared but not defined.
class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

/// The environment in which a code is executed.
class Environment {
  /// The environment in which a code is executed.
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

  /// Gets the value of the variable.
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

  /// Get the value of a variable in the environment of the given [distance].
  Object? getAt(int distance, Token name) {
    return _ancestor(distance).get(name);
  }

  /// Get the value of a variable from its [lexeme] in the environment of the
  /// given [distance].
  Object? getLexemeAt(int distance, String lexeme) {
    return _ancestor(distance)._values[lexeme];
  }

  Environment _ancestor(int distance) {
    var environment = this;
    for (int i = 0; i < distance; i++) {
      environment = environment.enclosing!;
    }
    return environment;
  }

  /// Assign a value to a variable in the current environment.
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

  /// Assign a value to a variable in an environment at a given [distance].
  void assignAt(int distance, Token name, Object? value) {
    _ancestor(distance).assign(name, value);
  }
}

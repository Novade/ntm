import 'package:ntm/src/callable.dart';
import 'package:ntm/src/environment.dart';
import 'package:ntm/src/interpreter.dart';
import 'package:ntm/src/statement.dart';

class NtmFunction implements Callable {
  const NtmFunction({
    required this.declaration,
  });

  final FunctionStatement declaration;

  @override
  int get arity => declaration.params.length;

  @override
  Object? call(Interpreter interpreter, Iterable<Object?> arguments) {
    // TODO: Should we use the current environment instead of using the global
    // one?
    final environment = Environment(enclosing: interpreter.globals);
    for (var i = 0; i < declaration.params.length; i++) {
      environment.define(
        declaration.params.elementAt(i).lexeme,
        arguments.elementAt(i),
      );
    }
    interpreter.executeBlock(declaration.body, environment);
    return null;
  }

  @override
  String describe() {
    return '<fn ${declaration.name.lexeme}>';
  }
}

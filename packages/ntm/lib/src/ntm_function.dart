import 'package:ntm/src/callable.dart';
import 'package:ntm/src/environment.dart';
import 'package:ntm/src/interpreter.dart';
import 'package:ntm/src/return_exception.dart';
import 'package:ntm/src/statement.dart';

// TODO: Allow anonymous functions
// https://www.craftinginterpreters.com/functions.html#challenges
class NtmFunction implements Callable {
  const NtmFunction({
    required this.declaration,
    required this.closure,
  });

  final FunctionStatement declaration;
  final Environment closure;

  @override
  int get arity => declaration.params.length;

  @override
  Object? call(Interpreter interpreter, Iterable<Object?> arguments) {
    final environment = Environment(enclosing: closure);
    for (var i = 0; i < declaration.params.length; i++) {
      environment.define(
        declaration.params.elementAt(i).lexeme,
        arguments.elementAt(i),
      );
    }
    // We wrap the call to [interpreter.executeBlock] in a try-catch block. When
    // it catches a return exception, it pulls out the value and makes that the
    // return value from [call]. If it never catches one of these exceptions, it
    // means the function reached the end of its body without hitting a return
    // statement. In that case, it implicitly returns `null`.
    try {
      interpreter.executeBlock(declaration.body, environment);
    } on ReturnException catch (returnValue) {
      return returnValue.value;
    }
    return null;
  }

  @override
  String describe() {
    return '<fn ${declaration.name.lexeme}>';
  }
}

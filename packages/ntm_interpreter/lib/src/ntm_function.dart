import 'package:ntm_ast/ntm_ast.dart';

import 'callable.dart';
import 'environment.dart';
import 'interpreter.dart';
import 'ntm_instance.dart';
import 'return_exception.dart';

// TODO: Allow anonymous functions
// https://www.craftinginterpreters.com/functions.html#challenges

/// A function in the Ntm language.
class NtmFunction implements Callable {
  /// A function in the Ntm language.
  const NtmFunction({
    required this.declaration,
    required this.closure,
    required this.isInitializer,
  });

  /// The declaration of the function.
  final FunctionStatement declaration;

  /// The closure of the function when it was created.
  final Environment closure;

  /// `true` if the function is an initializer of a class.
  final bool isInitializer;

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
      if (isInitializer) return closure.getLexemeAt(0, 'this');
      return returnValue.value;
    }
    if (isInitializer) return closure.getLexemeAt(0, 'this');
    return null;
  }

  /// Binds the function to the given [instance].
  NtmFunction bind(NtmInstance instance) {
    final environment = Environment(enclosing: closure);
    environment.define('this', instance);
    return NtmFunction(
      declaration: declaration,
      closure: environment,
      isInitializer: isInitializer,
    );
  }

  @override
  String describe() {
    return '<fn ${declaration.name.lexeme}>';
  }
}

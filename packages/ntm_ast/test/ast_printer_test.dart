import 'package:ntm_ast/ntm_ast.dart';
import 'package:ntm_core/ntm_core.dart';
import 'package:test/test.dart';

void main() {
  test('It should pretty print the ast', () {
    const expression = BinaryExpression(
      left: UnaryExpression(
        operator: Token(
          type: TokenType.minus,
          lexeme: '-',
          line: 1,
          column: 1,
        ),
        right: LiteralExpression(value: 123),
      ),
      operator: Token(
        type: TokenType.star,
        lexeme: '*',
        line: 1,
        column: 1,
      ),
      right: GroupingExpression(
        expression: LiteralExpression(value: 45.67),
      ),
    );
    expect(expression.accept(const AstPrinter()), '(* (- 123) (group 45.67))');
  });
}

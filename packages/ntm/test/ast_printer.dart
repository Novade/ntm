import 'package:ntm/src/ast_printer.dart';
import 'package:ntm/src/expression.dart';
import 'package:ntm/src/token.dart';
import 'package:ntm/src/token_type.dart';
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
    expect(expression.accept(const AstPrint()), '(* (- 123) (group 45.67))');
  });
}

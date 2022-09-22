enum TokenType {
  // Single-character tokens.

  /// `(`
  leftParenthesis,

  /// `)`
  rightParenthesis,

  /// `{`
  leftBrace,

  /// `}`
  rightBrace,

  /// `,`
  comma,

  /// `.`
  dot,

  /// `-`
  minus,

  /// `+`
  plus,

  /// `;`
  semicolon,

  /// `/`
  slash,

  /// `*`
  star,

  // One or two character tokens.

  /// `!`
  bang,

  /// `!=`
  bangEqual,

  /// `=`
  equal,

  /// `==`
  equalEqual,

  /// `>`
  greater,

  /// `>=`
  greaterEqual,

  /// `<`
  less,

  /// `<=`
  lessEqual,

  /// `||`
  pipePipe,

  /// `&&`
  andAnd,

  // literals.
  identifier,
  string,
  number,

  // keywords.

  /// `class`
  classKeyword,

  /// `else`
  elseKeyword,

  /// `false`
  falseKeyword,

  /// `fun`
  funKeyword,

  /// `for`
  forKeyword,

  /// `if`
  ifKeyword,

  /// `null`
  nullKeyword,

  /// `print`
  printKeyword,

  /// `return`
  returnKeyword,

  /// `super`
  superKeyword,

  /// `this`
  thisKeyword,

  /// `true`
  trueKeyword,

  /// `var`
  varKeyword,

  /// `while`
  whileKeyword,

  /// End of file.
  eof,
}

/// The different keywords of the ntm language.
const keywords = {
  'class': TokenType.classKeyword,
  'else': TokenType.elseKeyword,
  'false': TokenType.falseKeyword,
  'for': TokenType.forKeyword,
  'fun': TokenType.funKeyword,
  'if': TokenType.ifKeyword,
  'null': TokenType.nullKeyword,
  'print': TokenType.printKeyword,
  'return': TokenType.returnKeyword,
  'super': TokenType.superKeyword,
  'this': TokenType.thisKeyword,
  'true': TokenType.trueKeyword,
  'var': TokenType.varKeyword,
  'while': TokenType.whileKeyword,
};

enum TokenType {
  // Single-character tokens.

  /// `(`
  leftParenthesis,
  rightParenthesis,

  /// `{`
  leftBrace,

  /// `}`
  rightBrace,
  comma,
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

  // literals.
  identifier,
  string,
  number,

  // keywords.
  andKeyword,
  classKeyword,
  elseKeyword,

  /// `false`
  falseKeyword,

  funKeyword,
  forKeyword,
  ifKeyword,

  /// `null`
  nullKeyword,
  pipePipe,
  printKeyword,
  returnKeyword,
  superKeyword,
  thisKeyword,

  /// `true`
  trueKeyword,
  varKeyword,
  whileKeyword,

  /// End of file.
  eof,
}

const keywords = {
  'class': TokenType.classKeyword,
  'else': TokenType.elseKeyword,
  'false': TokenType.falseKeyword,
  'for': TokenType.forKeyword,
  'fun': TokenType.funKeyword,
  'if': TokenType.ifKeyword,
  'nil': TokenType.nullKeyword,
  'print': TokenType.printKeyword,
  'return': TokenType.returnKeyword,
  'super': TokenType.superKeyword,
  'this': TokenType.thisKeyword,
  'true': TokenType.trueKeyword,
  'var': TokenType.varKeyword,
  'while': TokenType.whileKeyword,
};

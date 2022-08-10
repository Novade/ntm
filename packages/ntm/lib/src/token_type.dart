enum TokenType {
  // Single-character tokens.
  leftParenthesis,
  rightParenthesis,
  leftBrace,
  rightBrace,
  comma,
  dot,
  minus,
  plus,
  semicolon,
  slash,
  star,

  // One or two character tokens.
  bang,
  bangEqual,
  equal,
  equalEqual,
  greater,
  greaterEqual,
  less,
  lessEqual,

  // literals.
  identifier,
  string,
  number,

  // keywords.
  andKeyword,
  classKeyword,
  elseKeyword,
  falseKeyword,
  funKeyword,
  forKeyword,
  ifKeyword,
  nilKeyword,
  orKeyword,
  printKeyword,
  returnKeyword,
  superKeyword,
  thisKeyword,
  trueKeyword,
  varKeyword,
  whileKeyword,

  /// End of file.
  eof,
}

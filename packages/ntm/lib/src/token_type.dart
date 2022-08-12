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
  pipePipe,
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

const keywords = {
  'class': TokenType.classKeyword,
  'else': TokenType.elseKeyword,
  'false': TokenType.falseKeyword,
  'for': TokenType.forKeyword,
  'fun': TokenType.funKeyword,
  'if': TokenType.ifKeyword,
  'nil': TokenType.nilKeyword,
  'print': TokenType.printKeyword,
  'return': TokenType.returnKeyword,
  'super': TokenType.superKeyword,
  'this': TokenType.thisKeyword,
  'true': TokenType.trueKeyword,
  'var': TokenType.varKeyword,
  'while': TokenType.whileKeyword,
};

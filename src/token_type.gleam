pub type TokenType {
  // Single-character tokens.
  LeftParen
  RightParen

  // End of file.
  Eof
}

pub fn to_string(token_type: TokenType) -> String {
  case token_type {
    LeftParen -> "LEFT_PAREN"
    RightParen -> "RIGHT_PAREN"
    Eof -> "EOF"
  }
}

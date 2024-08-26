pub type TokenType {
  // Single-character tokens.
  LeftParen
  RightParen
  LeftBrace
  RightBrace
  Comma
  Dot
  Minus
  Plus
  Semicolon
  Star

  // End of file.
  Eof
}

pub fn to_string(token_type: TokenType) -> String {
  case token_type {
    LeftParen -> "LEFT_PAREN"
    RightParen -> "RIGHT_PAREN"
    LeftBrace -> "LEFT_BRACE"
    RightBrace -> "RIGHT_BRACE"
    Comma -> "COMMA"
    Dot -> "DOT"
    Minus -> "MINUS"
    Plus -> "PLUS"
    Semicolon -> "SEMICOLON"
    Star -> "STAR"
    Eof -> "EOF"
  }
}

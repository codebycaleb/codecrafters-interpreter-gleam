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

  // One or two character tokens.
  Bang
  BangEqual
  Equal
  EqualEqual
  Less
  LessEqual
  Greater
  GreaterEqual

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

    Bang -> "BANG"
    BangEqual -> "BANG_EQUAL"
    Equal -> "EQUAL"
    EqualEqual -> "EQUAL_EQUAL"
    Less -> "LESS"
    LessEqual -> "LESS_EQUAL"
    Greater -> "GREATER"
    GreaterEqual -> "GREATER_EQUAL"

    Eof -> "EOF"
  }
}

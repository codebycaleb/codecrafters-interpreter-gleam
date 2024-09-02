import gleam/string

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
  Slash
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

  // Literals.
  Identifier
  String
  Number

  // Keywords.
  And
  Class
  Else
  False
  Fun
  For
  If
  Nil
  Or
  Print
  Return
  Super
  This
  True
  Var
  While

  // End of file.
  Eof
}

pub fn to_string(token_type: TokenType) -> String {
  case token_type {
    LeftParen -> "LEFT_PAREN"
    RightParen -> "RIGHT_PAREN"
    LeftBrace -> "LEFT_BRACE"
    RightBrace -> "RIGHT_BRACE"
    BangEqual -> "BANG_EQUAL"
    EqualEqual -> "EQUAL_EQUAL"
    LessEqual -> "LESS_EQUAL"
    GreaterEqual -> "GREATER_EQUAL"
    _ -> token_type |> string.inspect |> string.uppercase
  }
}

pub fn identifier_to_token_type(identifier: String) -> TokenType {
  case identifier {
    "and" -> And
    "class" -> Class
    "else" -> Else
    "false" -> False
    "fun" -> Fun
    "for" -> For
    "if" -> If
    "nil" -> Nil
    "or" -> Or
    "print" -> Print
    "return" -> Return
    "super" -> Super
    "this" -> This
    "true" -> True
    "var" -> Var
    "while" -> While

    _ -> Identifier
  }
}

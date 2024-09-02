import gleam/dynamic.{type Dynamic}
import gleam/float
import gleam/result
import gleam/string

pub type Token {
  Token(token_type: TokenType, lexeme: String, literal: Dynamic, line: Int)
}

pub fn to_string(token: Token) -> String {
  let Token(token_type, lexeme, literal, _) = token
  type_string(token_type) <> " " <> lexeme <> " " <> literal_to_string(literal)
}

pub fn literal_to_string(literal: Dynamic) -> String {
  case dynamic.classify(literal) {
    "Nil" -> "null"
    "Float" -> literal |> dynamic.float |> result.unwrap(0.0) |> float.to_string
    "String" -> literal |> dynamic.string |> result.unwrap("")
    _ -> panic
  }
}

pub fn literal_to_float(literal: Dynamic) -> Float {
  case dynamic.classify(literal) {
    "Float" -> literal |> dynamic.float |> result.unwrap(0.0)
    _ -> panic
  }
}

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

fn type_string(token_type: TokenType) -> String {
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

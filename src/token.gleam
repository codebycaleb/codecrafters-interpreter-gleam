import gleam/float
import gleam/int
import token_type.{type TokenType}

pub type Literal {
  Nil
  Int(Int)
  Float(Float)
  String(String)
}

pub type ProcessedToken {
  Token(token_type: TokenType, lexeme: String, literal: Literal, line: Int)
}

pub fn to_string(token: ProcessedToken) -> String {
  let Token(token_type, lexeme, literal, _) = token
  token_type.to_string(token_type)
  <> " "
  <> lexeme
  <> " "
  <> literal_to_string(literal)
}

fn literal_to_string(literal: Literal) -> String {
  case literal {
    Nil -> "null"
    Int(i) -> int.to_string(i)
    Float(f) -> float.to_string(f)
    String(s) -> s
  }
}

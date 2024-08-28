import gleam/float
import token_type.{type TokenType}

pub type Literal {
  Nil
  Number(Float)
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
    Number(f) -> float.to_string(f)
    String(s) -> s
  }
}

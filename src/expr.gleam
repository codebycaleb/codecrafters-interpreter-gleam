import gleam/bool
import gleam/float
import gleam/string
import token.{type Token}

pub type Literal {
  Number(value: Float)
  String(value: String)
  Boolean(value: Bool)
  Nil(value: Nil)
}

pub type Expr {
  Literal(value: Literal)
  Unary(op: Token, right: Expr)
  Grouping(expr: Expr)
}

pub fn to_string(expr: Expr) -> String {
  case expr {
    Literal(literal) -> literal_string(literal)
    Unary(op, right) -> "(" <> op.lexeme <> " " <> to_string(right) <> ")"
    Grouping(expr) -> "(group " <> to_string(expr) <> ")"
  }
}

fn literal_string(literal: Literal) -> String {
  case literal {
    Number(value) -> float.to_string(value)
    String(value) -> value
    Boolean(value) -> value |> bool.to_string |> string.lowercase
    Nil(_) -> "nil"
  }
}

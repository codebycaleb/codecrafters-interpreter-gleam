import expr.{type Expr}
import token.{type Token}

pub fn parse(token: Token) -> Expr {
  primary(token)
}

fn primary(token: Token) -> Expr {
  case token.token_type {
    token.False -> expr.Literal(expr.Boolean(False))
    token.True -> expr.Literal(expr.Boolean(True))
    token.Nil -> expr.Literal(expr.Nil(Nil))
    token.Number ->
      expr.Literal(expr.Number(token.literal_to_float(token.literal)))
    token.String ->
      expr.Literal(expr.String(token.literal_to_string(token.literal)))
    _ -> panic
  }
}

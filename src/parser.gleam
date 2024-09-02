import expr.{type Expr}
import token.{type Token}

pub fn parse(tokens: List(Token)) -> Expr {
  case tokens {
    [] -> panic
    [token, ..rest] -> {
      unary(token, rest)
    }
  }
}

fn unary(token: Token, rest: List(Token)) -> Expr {
  case token.token_type, rest {
    token.Bang, [next, ..rest] -> expr.Unary(token, unary(next, rest))
    token.Minus, [next, ..rest] -> expr.Unary(token, unary(next, rest))
    _, _ -> primary(token, rest)
  }
}

fn primary(token: Token, rest: List(Token)) -> Expr {
  case token.token_type {
    token.False -> expr.Literal(expr.Boolean(False))
    token.True -> expr.Literal(expr.Boolean(True))
    token.Nil -> expr.Literal(expr.Nil(Nil))
    token.Number ->
      expr.Literal(expr.Number(token.literal_to_float(token.literal)))
    token.String ->
      expr.Literal(expr.String(token.literal_to_string(token.literal)))
    token.LeftParen -> grouping(rest)
    _ -> panic
  }
}

fn grouping(tokens) {
  case tokens {
    [token, ..rest] -> expr.Grouping(unary(token, rest))
    _ -> panic
  }
}

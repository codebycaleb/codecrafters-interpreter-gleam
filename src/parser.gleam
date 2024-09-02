import expr.{type Expr}
import token.{type Token}

type ParseResult {
  ParseResult(expr: Expr, rest: List(Token))
}

pub fn parse(tokens: List(Token)) -> Expr {
  case tokens {
    [] -> panic
    [token, ..rest] -> {
      parse_token(token, rest).expr
    }
  }
}

fn parse_token(token, rest) -> ParseResult {
  term(token, rest)
}

fn term(token: Token, rest: List(Token)) -> ParseResult {
  let ParseResult(expr, rest) = factor(token, rest)
  term_recurse(expr, rest)
}

fn term_recurse(left: Expr, rest: List(Token)) -> ParseResult {
  case rest {
    [maybe_term, ..after_term] -> {
      case maybe_term.token_type {
        token.Minus | token.Plus -> {
          case after_term {
            [next, ..rest] -> {
              let op = maybe_term
              let ParseResult(right, rest) = factor(next, rest)
              term_recurse(expr.Binary(op, left, right), rest)
            }
            _ -> panic
          }
        }
        _ -> ParseResult(left, rest)
      }
    }
    _ -> ParseResult(left, rest)
  }
}

fn factor(token: Token, rest: List(Token)) -> ParseResult {
  let ParseResult(expr, rest) = unary(token, rest)
  factor_recurse(expr, rest)
}

fn factor_recurse(left: Expr, rest: List(Token)) -> ParseResult {
  case rest {
    [maybe_factor, ..after_factor] -> {
      case maybe_factor.token_type {
        token.Star | token.Slash -> {
          case after_factor {
            [next, ..rest] -> {
              let op = maybe_factor
              let ParseResult(right, rest) = unary(next, rest)
              factor_recurse(expr.Binary(op, left, right), rest)
            }
            _ -> panic
          }
        }
        _ -> ParseResult(left, rest)
      }
    }
    _ -> ParseResult(left, rest)
  }
}

fn unary(token: Token, rest: List(Token)) -> ParseResult {
  case token.token_type, rest {
    token.Bang, [next, ..rest] | token.Minus, [next, ..rest] -> {
      let ParseResult(right, rest) = unary(next, rest)
      ParseResult(expr.Unary(token, right), rest)
    }
    _, _ -> primary(token, rest)
  }
}

fn primary(token: Token, rest: List(Token)) -> ParseResult {
  case token.token_type {
    token.False -> ParseResult(expr.Literal(expr.Boolean(False)), rest)
    token.True -> ParseResult(expr.Literal(expr.Boolean(True)), rest)
    token.Nil -> ParseResult(expr.Literal(expr.Nil(Nil)), rest)
    token.Number ->
      ParseResult(
        expr.Literal(expr.Number(token.literal_to_float(token.literal))),
        rest,
      )
    token.String ->
      ParseResult(
        expr.Literal(expr.String(token.literal_to_string(token.literal))),
        rest,
      )
    token.LeftParen -> grouping(rest)
    _ -> panic
  }
}

fn grouping(tokens: List(Token)) -> ParseResult {
  case tokens {
    [token, ..rest] -> {
      let ParseResult(expr, rest) = parse_token(token, rest)
      case rest {
        [token, ..rest] -> {
          case token.token_type {
            token.RightParen -> ParseResult(expr.Grouping(expr), rest)
            _ -> panic
          }
        }
        _ -> panic
      }
    }
    _ -> panic
  }
}

import expr.{type Expr}
import gleam/list
import token.{type Token, type TokenType}

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
  equality(token, rest)
}

fn equality(token: Token, rest: List(Token)) -> ParseResult {
  let ParseResult(expr, rest) = comparison(token, rest)
  recurse(expr, rest, [token.BangEqual, token.EqualEqual], comparison)
}

fn comparison(token: Token, rest: List(Token)) -> ParseResult {
  let ParseResult(expr, rest) = term(token, rest)
  recurse(
    expr,
    rest,
    [token.Greater, token.GreaterEqual, token.Less, token.LessEqual],
    term,
  )
}

fn term(token: Token, rest: List(Token)) -> ParseResult {
  let ParseResult(expr, rest) = factor(token, rest)
  recurse(expr, rest, [token.Minus, token.Plus], factor)
}

fn factor(token: Token, rest: List(Token)) -> ParseResult {
  let ParseResult(expr, rest) = unary(token, rest)
  recurse(expr, rest, [token.Slash, token.Star], unary)
}

fn recurse(
  left: Expr,
  rest: List(Token),
  ops: List(TokenType),
  next_fn,
) -> ParseResult {
  case rest {
    [maybe_op, ..after_op] -> {
      case list.find(ops, fn(x) { x == maybe_op.token_type }) {
        Ok(_) -> {
          case after_op {
            [next, ..rest] -> {
              let op = maybe_op
              let ParseResult(right, rest) = next_fn(next, rest)
              recurse(expr.Binary(op, left, right), rest, ops, next_fn)
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

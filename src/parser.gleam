import expr.{type Expr}
import gleam/list
import token.{type Token, type TokenType}

type Parsed {
  Parsed(expr: Expr, rest: List(Token))
}

pub fn parse(tokens: List(Token)) -> Result(Expr, String) {
  case tokens {
    [] -> panic
    [token, ..rest] -> {
      case parse_token(token, rest) {
        Ok(Parsed(expr, [token.Token(token_type: token.Eof, ..)])) -> Ok(expr)
        Ok(_) -> Error("Unexpected tokens after parsing")
        Error(e) -> Error(e)
      }
    }
  }
}

fn parse_token(token, rest) -> Result(Parsed, String) {
  equality(token, rest)
}

fn equality(token: Token, rest: List(Token)) -> Result(Parsed, String) {
  case comparison(token, rest) {
    Ok(Parsed(expr, rest)) ->
      recurse(expr, rest, [token.BangEqual, token.EqualEqual], comparison)
    Error(e) -> err(e)
  }
}

fn comparison(token: Token, rest: List(Token)) -> Result(Parsed, String) {
  case term(token, rest) {
    Ok(Parsed(expr, rest)) ->
      recurse(
        expr,
        rest,
        [token.Less, token.LessEqual, token.Greater, token.GreaterEqual],
        term,
      )
    Error(e) -> err(e)
  }
}

fn term(token: Token, rest: List(Token)) -> Result(Parsed, String) {
  case factor(token, rest) {
    Ok(Parsed(expr, rest)) ->
      recurse(expr, rest, [token.Minus, token.Plus], factor)
    Error(e) -> err(e)
  }
}

fn factor(token: Token, rest: List(Token)) -> Result(Parsed, String) {
  case unary(token, rest) {
    Ok(Parsed(expr, rest)) ->
      recurse(expr, rest, [token.Slash, token.Star], unary)
    Error(e) -> err(e)
  }
}

fn recurse(
  left: Expr,
  rest: List(Token),
  ops: List(TokenType),
  next_fn: fn(Token, List(Token)) -> Result(Parsed, String),
) -> Result(Parsed, String) {
  case rest {
    [op, next, ..after_op] -> {
      case list.find(ops, fn(x) { x == op.token_type }) {
        Ok(_) -> {
          case next_fn(next, after_op) {
            Ok(Parsed(right, rest)) ->
              recurse(expr.Binary(op, left, right), rest, ops, next_fn)
            Error(e) -> err(e)
          }
        }
        Error(Nil) -> ok(left, rest)
      }
    }
    _ -> ok(left, rest)
  }
}

fn unary(token: Token, rest: List(Token)) -> Result(Parsed, String) {
  case token.token_type, rest {
    token.Bang, [next, ..rest] | token.Minus, [next, ..rest] -> {
      case unary(next, rest) {
        Ok(Parsed(right, rest)) -> ok(expr.Unary(token, right), rest)
        Error(e) -> err(e)
      }
    }
    _, _ -> primary(token, rest)
  }
}

fn primary(token: Token, rest: List(Token)) -> Result(Parsed, String) {
  case token.token_type {
    token.False -> ok(expr.Literal(expr.Boolean(False)), rest)
    token.True -> ok(expr.Literal(expr.Boolean(True)), rest)
    token.Nil -> ok(expr.Literal(expr.Nil(Nil)), rest)
    token.Number ->
      ok(expr.Literal(expr.Number(token.literal_to_float(token.literal))), rest)
    token.String ->
      ok(
        expr.Literal(expr.String(token.literal_to_string(token.literal))),
        rest,
      )
    token.LeftParen -> grouping(rest)
    _ -> err("Expected expression.")
  }
}

fn grouping(tokens: List(Token)) -> Result(Parsed, String) {
  case tokens {
    [token, ..rest] -> {
      case parse_token(token, rest) {
        Ok(Parsed(expr, rest)) -> {
          case rest {
            [token, ..rest] -> {
              case token.token_type {
                token.RightParen -> ok(expr.Grouping(expr), rest)
                _ -> err("Expected ')', got " <> token.to_string(token))
              }
            }
            _ -> err("Expected ')', got EOF")
          }
        }
        Error(e) -> err(e)
      }
    }
    _ -> err("Expected expression.")
  }
}

fn ok(expr: Expr, rest: List(Token)) -> Result(Parsed, String) {
  Ok(Parsed(expr, rest))
}

fn err(message: String) -> Result(Parsed, String) {
  Error(message)
}

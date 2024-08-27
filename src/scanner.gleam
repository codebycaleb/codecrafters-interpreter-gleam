import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import token.{type Token, BasicToken}
import token_type.{
  type TokenType, Bang, BangEqual, Comma, Dot, Eof, Equal, EqualEqual, Greater,
  GreaterEqual, LeftBrace, LeftParen, Less, LessEqual, Minus, Plus, RightBrace,
  RightParen, Semicolon, Star,
}

pub type Scanner {
  Scanner(
    source: String,
    tokens: List(Token),
    errors: List(String),
    acc: List(String),
    line: Int,
  )
}

pub fn new(source: String) -> Scanner {
  Scanner(source, [], [], [], 1)
}

pub fn scan_tokens(scanner: Scanner) -> Scanner {
  let scanner = scan_token(scanner)
  case scanner.tokens {
    [BasicToken(Eof, _, _, _), ..] -> scanner
    _ -> scan_tokens(Scanner(..scanner, acc: []))
  }
}

fn scan_token(scanner: Scanner) -> Scanner {
  case advance_token(scanner) {
    None -> add_token(scanner, Eof)
    Some(#(token, scanner)) ->
      case token {
        "(" -> add_token(scanner, LeftParen)
        ")" -> add_token(scanner, RightParen)
        "{" -> add_token(scanner, LeftBrace)
        "}" -> add_token(scanner, RightBrace)
        "," -> add_token(scanner, Comma)
        "." -> add_token(scanner, Dot)
        "-" -> add_token(scanner, Minus)
        "+" -> add_token(scanner, Plus)
        ";" -> add_token(scanner, Semicolon)
        "*" -> add_token(scanner, Star)
        "!" -> peek_add_token(scanner, "=", Bang, BangEqual)
        "=" -> peek_add_token(scanner, "=", Equal, EqualEqual)
        "<" -> peek_add_token(scanner, "=", Less, LessEqual)
        ">" -> peek_add_token(scanner, "=", Greater, GreaterEqual)

        _ -> add_error(scanner, "Unexpected character: " <> token)
      }
  }
}

fn advance_token(scanner: Scanner) -> Option(#(String, Scanner)) {
  case string.pop_grapheme(scanner.source) {
    Error(Nil) -> None
    Ok(#(grapheme, rest)) ->
      Some(#(
        grapheme,
        Scanner(..scanner, source: rest, acc: [grapheme, ..scanner.acc]),
      ))
  }
}

fn add_token(scanner: Scanner, token_type: TokenType) -> Scanner {
  let lexeme = scanner.acc |> list.reverse |> string.concat
  let literal = Nil
  let line = scanner.line
  let token = BasicToken(token_type, lexeme, literal, line)
  Scanner(..scanner, tokens: [token, ..scanner.tokens])
}

fn add_error(scanner: Scanner, message: String) -> Scanner {
  let line = scanner.line
  let error = "[line " <> int.to_string(line) <> "] Error: " <> message
  Scanner(..scanner, errors: [error, ..scanner.errors])
}

fn peek_add_token(
  scanner: Scanner,
  expected: String,
  tt_if_not_match: TokenType,
  tt_if_match: TokenType,
) -> Scanner {
  case advance_token(scanner) {
    None -> add_token(scanner, tt_if_not_match)
    Some(#(token, peeked_scanner)) ->
      case token {
        t if t == expected -> add_token(peeked_scanner, tt_if_match)
        _ -> add_token(scanner, tt_if_not_match)
      }
  }
}

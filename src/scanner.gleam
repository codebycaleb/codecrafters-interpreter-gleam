import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import token.{type ProcessedToken, Token}
import token_type.{
  type TokenType, Bang, BangEqual, Comma, Dot, Eof, Equal, EqualEqual, Greater,
  GreaterEqual, Identifier, LeftBrace, LeftParen, Less, LessEqual, Minus, Number,
  Plus, RightBrace, RightParen, Semicolon, Slash, Star, String,
}

pub type Scanner {
  Scanner(
    source: String,
    tokens: List(ProcessedToken),
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
    [Token(Eof, ..), ..] -> scanner
    _ -> scan_tokens(Scanner(..scanner, acc: []))
  }
}

fn scan_token(scanner: Scanner) -> Scanner {
  let scanned = case advance_token(scanner) {
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
        "/" -> handle_slash(scanner)
        " " | "\r" | "\t" -> scanner
        "\n" -> handle_newline(scanner)
        "\"" -> handle_string(scanner)
        c -> {
          case is_digit(c) {
            True -> handle_number(scanner)
            False ->
              case is_alpha(c) {
                True -> handle_identifier(scanner)
                False -> add_error(scanner, "Unexpected character: " <> token)
              }
          }
        }
      }
  }
  // clear acc
  Scanner(..scanned, acc: [])
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
  let literal = case token_type {
    String ->
      token.String(lexeme |> string.drop_left(1) |> string.drop_right(1))
    Number ->
      case float.parse(lexeme) {
        Ok(f) -> token.Number(f)
        Error(_) ->
          case int.parse(lexeme) {
            Ok(i) -> token.Number(int.to_float(i))
            Error(_) -> panic
          }
      }
    _ -> token.Nil
  }
  let line = scanner.line
  let token = Token(token_type, lexeme, literal, line)
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

fn handle_slash(scanner: Scanner) -> Scanner {
  case advance_token(scanner) {
    None -> add_token(scanner, Slash)
    Some(#("/", peeked_scanner)) -> consume_until_newline(peeked_scanner)
    _ -> add_token(scanner, Slash)
  }
}

fn consume_until_newline(scanner: Scanner) -> Scanner {
  case advance_token(scanner) {
    None -> scanner
    Some(#("\n", peeked_scanner)) -> handle_newline(peeked_scanner)
    Some(#(_, peeked_scanner)) -> consume_until_newline(peeked_scanner)
  }
}

fn handle_string(scanner: Scanner) -> Scanner {
  consume_until_quote(scanner)
}

fn consume_until_quote(scanner: Scanner) -> Scanner {
  case advance_token(scanner) {
    Some(#("\"", scanned)) -> add_token(scanned, String)
    Some(#("\n", scanned)) -> consume_until_quote(handle_newline(scanned))
    Some(#(_, scanned)) -> consume_until_quote(scanned)
    None -> add_error(scanner, "Unterminated string.")
  }
}

fn is_digit(str: String) -> Bool {
  case str {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

fn is_alpha(str: String) -> Bool {
  case string.to_utf_codepoints(str) {
    [c] -> {
      let i = string.utf_codepoint_to_int(c)
      i >= 65 && i <= 90 || i == 95 || i >= 97 && i <= 122
    }
    _ -> False
  }
}

fn handle_number(scanner: Scanner) -> Scanner {
  let int_scanner = consume_until_non_digit(scanner)
  let float_scanner = case advance_token(int_scanner) {
    Some(#(".", scanner_with_dot)) -> {
      case advance_token(scanner_with_dot) {
        Some(#(c, fractional_scanner)) ->
          case is_digit(c) {
            True -> consume_until_non_digit(fractional_scanner)
            False -> int_scanner
          }
        None -> int_scanner
      }
    }
    _ -> int_scanner
  }
  add_token(float_scanner, Number)
}

fn consume_until_non_digit(scanner: Scanner) -> Scanner {
  case advance_token(scanner) {
    Some(#(c, scanned)) ->
      case is_digit(c) {
        True -> consume_until_non_digit(scanned)
        False -> scanner
      }
    None -> scanner
  }
}

fn handle_identifier(scanner: Scanner) -> Scanner {
  add_token(consume_until_non_alphanumeric(scanner), Identifier)
}

fn consume_until_non_alphanumeric(scanner: Scanner) -> Scanner {
  case advance_token(scanner) {
    Some(#(c, scanned)) ->
      case is_alpha(c) || is_digit(c) {
        True -> consume_until_non_alphanumeric(scanned)
        False -> scanner
      }
    None -> scanner
  }
}

fn handle_newline(scanner: Scanner) -> Scanner {
  Scanner(..scanner, line: scanner.line + 1)
}

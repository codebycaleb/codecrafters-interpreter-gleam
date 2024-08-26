import gleam/list
import gleam/option.{None, Some}
import gleam/string
import token.{type Token, BasicToken}
import token_type.{type TokenType}

pub type Scanner {
  Scanner(source: String, tokens: List(Token), acc: List(String), line: Int)
}

pub fn new(source: String) {
  Scanner(source, [], [], 1)
}

pub fn scan_tokens(scanner: Scanner) {
  let scanner = scan_token(scanner)
  case scanner.tokens {
    [BasicToken(token_type.Eof, _, _, _), ..] -> list.reverse(scanner.tokens)
    _ -> scan_tokens(Scanner(..scanner, acc: []))
  }
}

fn scan_token(scanner: Scanner) {
  case advance_token(scanner) {
    None -> add_token(scanner, token_type.Eof)
    Some(#(token, scanner)) ->
      case token {
        "(" -> add_token(scanner, token_type.LeftParen)
        ")" -> add_token(scanner, token_type.RightParen)
        "{" -> add_token(scanner, token_type.LeftBrace)
        "}" -> add_token(scanner, token_type.RightBrace)
        _ -> panic
      }
  }
}

fn advance_token(scanner: Scanner) {
  case string.pop_grapheme(scanner.source) {
    Error(Nil) -> None
    Ok(#(grapheme, rest)) ->
      Some(#(
        grapheme,
        Scanner(..scanner, source: rest, acc: [grapheme, ..scanner.acc]),
      ))
  }
}

fn add_token(scanner: Scanner, token_type: TokenType) {
  let lexeme = string.concat(scanner.acc)
  let literal = Nil
  let line = scanner.line
  let token = BasicToken(token_type, lexeme, literal, line)
  Scanner(..scanner, tokens: [token, ..scanner.tokens])
}

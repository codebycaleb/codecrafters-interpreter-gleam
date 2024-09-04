import expr
import gleam/io
import gleam/list
import parser

import argv
import simplifile

import scanner
import token.{type Token}

pub fn main() {
  let args = argv.load().arguments

  case args {
    ["tokenize", filename] -> {
      filename
      |> read_file
      |> scan_file
      |> output_scanner_results
      |> check_for_scanner_errors

      exit(0)
    }
    ["parse", filename] -> {
      let scanned: scanner.Scanner =
        filename
        |> read_file
        |> scan_file
        |> check_for_scanner_errors

      scanned.tokens
      |> parser.parse
      |> output_parser_results
      |> check_for_parser_errors

      exit(0)
    }
    _ -> {
      io.println_error("Usage: ./lox.sh [tokenize | parse] <filename>")
      exit(1)
    }
  }
}

fn check_for_scanner_errors(scanner: scanner.Scanner) {
  case scanner.errors {
    [] -> Nil
    _ -> {
      print_errors(scanner.errors)
      exit(65)
    }
  }
  scanner
}

fn check_for_parser_errors(result: Result(expr.Expr, String)) {
  case result {
    Ok(_) -> Nil
    Error(e) -> {
      io.println_error(e)
      exit(65)
    }
  }
}

fn read_file(filename: String) {
  case simplifile.read(filename) {
    Ok(contents) -> {
      contents
    }
    Error(_) -> {
      ""
    }
  }
}

fn scan_file(contents: String) {
  contents
  |> scanner.new
  |> scanner.scan_tokens
}

fn output_scanner_results(scanner: scanner.Scanner) {
  print_tokens(scanner.tokens)
  scanner
}

fn output_parser_results(result: Result(expr.Expr, String)) {
  case result {
    Ok(expr) -> {
      expr
      |> expr.to_string
      |> io.println
    }
    Error(_) -> Nil
  }
  result
}

fn print_tokens(tokens: List(Token)) {
  tokens
  |> list.map(token.to_string)
  |> list.each(io.println)
}

fn print_errors(errors: List(String)) {
  errors
  |> list.each(io.println_error)
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Nil

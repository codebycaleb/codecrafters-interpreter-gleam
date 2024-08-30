import gleam/io
import gleam/list

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
    _ -> {
      io.println_error("Usage: ./lox.sh tokenize <filename>")
      exit(1)
    }
  }
}

fn check_for_scanner_errors(scanner: scanner.Scanner) {
  case scanner.errors {
    [] -> Nil
    _ -> exit(65)
  }
  scanner
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
  print_errors(scanner.errors)
  scanner
}

fn print_tokens(tokens: List(Token)) {
  tokens
  |> list.reverse
  |> list.map(token.to_string)
  |> list.each(io.println)
}

fn print_errors(errors: List(String)) {
  errors
  |> list.reverse
  |> list.each(io.println_error)
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Nil

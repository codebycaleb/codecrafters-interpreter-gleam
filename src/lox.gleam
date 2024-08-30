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
      run_file(filename)
    }
    _ -> {
      io.println_error("Usage: ./lox.sh tokenize <filename>")
      exit(1)
    }
  }
}

fn run_file(filename: String) {
  case simplifile.read(filename) {
    Ok(contents) -> {
      case run(contents) {
        scanner.Scanner(errors: [], ..) -> {
          exit(0)
        }
        _ -> {
          exit(65)
        }
      }
    }
    Error(error) -> {
      io.println_error("Error: " <> simplifile.describe_error(error))
      exit(1)
    }
  }
}

fn run(contents: String) {
  let scanned =
    contents
    |> scanner.new
    |> scanner.scan_tokens

  print_errors(scanned.errors)
  print_tokens(scanned.tokens)

  scanned
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

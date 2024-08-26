import gleam/io
import gleam/list

import argv
import simplifile

import scanner
import token

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
      run(contents)
      exit(0)
    }
    Error(error) -> {
      io.println_error("Error: " <> simplifile.describe_error(error))
      exit(1)
    }
  }
}

fn run(contents: String) {
  contents
  |> scanner.new
  |> scanner.scan_tokens
  |> list.map(fn(t) { token.to_string(t) })
  |> list.each(fn(s) { io.println(s) })
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Nil

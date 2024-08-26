import token_type.{type TokenType}

pub type Token {
  BasicToken(token_type: TokenType, lexeme: String, literal: Nil, line: Int)
}

pub fn to_string(token: Token) -> String {
  case token {
    BasicToken(token_type, lexeme, _literal, _line) -> {
      token_type.to_string(token_type) <> " " <> lexeme <> " null"
    }
  }
}

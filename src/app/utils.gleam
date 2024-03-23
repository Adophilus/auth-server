import gleam/http.{Https, Post}
import gleam/http/request
import gleam/json
import gleam/option.{None}
import gleam/result.{try}
import gleam/httpc
import gleam/io
import gleam/crypto
import gleam/bit_array
import app/config.{get_config}
import app/database.{type User}

pub fn send_welcome_email(email: String) {
  let assert Ok(config) = get_config()

  let req =
    request.Request(
      method: Post,
      headers: [
        #("content-type", "application/json"),
        #("authorization", "Bearer " <> config.resend_api_key),
      ],
      body: json.object([
          #("to", json.string(email)),
          #("from", json.string("Info <info@homeease.ng>")),
          #("subject", json.string("Welcome")),
          #("text", json.string("Your account has been created successfully!")),
        ])
        |> json.to_string,
      scheme: Https,
      host: "api.resend.com",
      port: None,
      path: "/emails",
      query: None,
    )

  use _resp <- try(httpc.send(req))

  Ok(Nil)
}

pub fn hash_password(password: String) -> String {
  password
  |> bit_array.from_string
  |> crypto.hash(crypto.Sha512, _)
  |> bit_array.base16_encode
}

pub fn compare_hash(plaintext: String, hashed_password: String) -> Bool {
  let hashed_bitarray =
    hashed_password
    |> bit_array.base16_decode
    |> result.unwrap(
      ""
      |> bit_array.from_string,
    )

  plaintext
  |> bit_array.from_string
  |> crypto.hash(crypto.Sha512, _)
  |> crypto.secure_compare(hashed_bitarray)
}

pub fn generate_token(user: User) -> String {
  let assert Ok(config) = get_config()

  let token =
    config.secret_key
    |> bit_array.from_string
    |> crypto.sign_message(
      json.object([#("email", json.string(user.email))])
        |> json.to_string
        |> bit_array.from_string,
      crypto.Sha512,
    )

  token
}

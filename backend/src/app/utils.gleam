import app/types
import gleam/bit_array
import gleam/crypto
import gleam/http.{Https, Post}
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/option.{None}
import gleam/result.{try}

pub fn send_welcome_email(cfg: types.EmailConfig, email: String) {
  let req =
    request.Request(
      method: Post,
      headers: [
        #("content-type", "application/json"),
        #("authorization", "Bearer " <> cfg.api_key),
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

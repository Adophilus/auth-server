import gleeunit
import gleeunit/should
import gleam/http/request
import gleam/http.{Http, Post}
import gleam/json
import gleam/io
import gleam/dynamic.{type Dynamic}
import gleam/option.{None, Some}
import app/config.{get_config}
import gleam/httpc
import dotenv_gleam

type AuthResponse {
  AuthResponse(message: String)
}

pub fn main() {
  dotenv_gleam.config()
  gleeunit.main()
}

pub fn should_create_an_account_test() {
  let assert Ok(config) = get_config()

  let email = "uchenna19of@gmail.com"
  let password = "uchenna19of@gmail.com"

  let assert Ok(res) =
    request.Request(
      method: Post,
      headers: [#("content-type", "application/json")],
      body: json.object([
          #("email", json.string(email)),
          #("password", json.string(password)),
        ])
        |> json.to_string,
      scheme: Http,
      host: "127.0.0.1",
      port: Some(config.port + 1),
      path: "/sign-up",
      query: None,
    )
    |> httpc.send

  should.equal(res.status, 201)
}

pub fn should_sign_into_created_account_test() {
  let assert Ok(config) = get_config()

  let email = "uchenna19of@gmail.com"
  let password = "uchenna19of@gmail.com"

  let assert Ok(res) =
    request.Request(
      method: Post,
      headers: [#("content-type", "application/json")],
      body: json.object([
          #("email", json.string(email)),
          #("password", json.string(password)),
        ])
        |> json.to_string,
      scheme: Http,
      host: "127.0.0.1",
      port: Some(config.port + 1),
      path: "/sign-in",
      query: None,
    )
    |> httpc.send

  should.equal(res.status, 200)
}

pub fn should_add_an_authentication_method_test() {
  let assert Ok(config) = get_config()

  let email = "uchenna19of@gmail.com"
  let password = "uchenna19of@gmail.com"

  let assert Ok(res) =
    request.Request(
      method: Post,
      headers: [#("content-type", "application/json")],
      body: json.object([
          #("email", json.string(email)),
          #("password", json.string(password)),
        ])
        |> json.to_string,
      scheme: Http,
      host: "127.0.0.1",
      port: Some(config.port + 1),
      path: "/sign-in",
      query: None,
    )
    |> httpc.send

  should.equal(res.status, 200)
  let assert Ok(auth_response) =
    res.body
    |> json.decode(fn(body: Dynamic) {
      let decoder =
        dynamic.decode1(AuthResponse, dynamic.field("message", dynamic.string))

      decoder(body)
    })

  let token = auth_response.message

  let assert Ok(res) =
    request.Request(
      method: Post,
      headers: [
        #("content-type", "application/json"),
        #("authorization", "Bearer " <> token),
      ],
      body: json.object([#("method", json.string("passkey"))])
        |> json.to_string,
      scheme: Http,
      host: "127.0.0.1",
      port: Some(config.port + 1),
      path: "/method",
      query: None,
    )
    |> httpc.send

  should.equal(res.status, 200)
}

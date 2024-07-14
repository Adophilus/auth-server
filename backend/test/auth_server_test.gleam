import app/config
import gleam/dynamic.{type Dynamic}
import gleam/http.{Http, Post}
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/io
import gleam/json
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should

type AuthResponse {
  AuthResponse(message: String)
}

pub fn main() {
  start_auth_server()
  gleeunit.main()
}

pub fn start_auth_server() {
  todo
}

pub fn should_create_an_account_test() {
  let assert Ok(config) = config.load()

  let email = "uchenna19of@gmail.com"

  let assert Ok(res) =
    request.Request(
      method: Post,
      headers: [#("content-type", "application/json")],
      body: json.object([#("email", json.string(email))])
        |> json.to_string,
      scheme: Http,
      host: "127.0.0.1",
      port: Some(config.proxy_port),
      path: "/sign-up",
      query: None,
    )
    |> httpc.send

  let assert Ok(access_token) =
    res
    |> response.get_header("x-access-token")

  io.println(access_token)

  should.equal(res.status, 201)
}

pub fn should_add_an_authentication_method_test() {
  let assert Ok(config) = config.load()

  let email = "uchenna19of@gmail.com"
  let password = "uchenna19of@gmail.com"

  let assert Ok(res) =
    request.Request(
      method: Post,
      headers: [#("content-type", "application/json")],
      body: json.object([
        #("type", json.string("CREDENTIALS_PW")),
        #("password", json.string(password)),
      ])
        |> json.to_string,
      scheme: Http,
      host: "127.0.0.1",
      port: Some(config.proxy_port),
      path: "/add-authentication-method",
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
      port: Some(config.proxy_port),
      path: "/method",
      query: None,
    )
    |> httpc.send

  should.equal(res.status, 200)
}

pub fn should_sign_into_created_account_test() {
  let assert Ok(config) = config.load()

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
      port: Some(config.proxy_port),
      path: "/sign-in",
      query: None,
    )
    |> httpc.send

  should.equal(res.status, 200)
}

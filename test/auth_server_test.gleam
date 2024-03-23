import gleeunit
import gleeunit/should
import gleam/http/request
import gleam/http.{Http, Post}
import gleam/json
import gleam/option.{None, Some}
import app/config.{get_config}
import gleam/httpc
import dotenv_gleam

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

pub fn should_add_an_authentication_method() {
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

import wisp
import gleam/http.{Post}
import gleam/result.{try}
import gleam/dynamic.{type Dynamic}
import gleam/io
import gleam/string
import gleam/json
import gleam/list
import app/database.{type Database}
import app/api_response.{type ApiResponse}
import app/utils
import gleam/http/request

type Body {
  Body(method: String)
}

fn decode_body(json: Dynamic) -> Result(Body, dynamic.DecodeErrors) {
  let decoder = dynamic.decode1(Body, dynamic.field("method", dynamic.string))

  decoder(json)
}

pub fn add_method(req: wisp.Request, db: Database) -> wisp.Response {
  use <- wisp.require_method(req, Post)
  use json_body <- wisp.require_json(req)

  check_authentication(req)
  |> result.map(fn(token) {
    token
    |> utils.decode_token
    |> result.map_error(fn(_) { api_response.err("Invalid token!", 400) })
    |> result.map(fn(token) {
      let req_body = decode_body(json_body)

      case req_body {
        Ok(_) -> api_response.ok("Welcome " <> token.email, 200)
        Error(_) -> api_response.err("Invalid body!", 400)
      }
    })
  })
  |> result.flatten
  |> result.unwrap_both
  |> api_response.to_wisp_response
}

fn check_authentication(req: wisp.Request) -> Result(String, ApiResponse) {
  use token <- try(
    request.get_header(req, "authorization")
    |> result.map(fn(header) { string.split(header, " ") })
    |> result.map(fn(header) { list.at(header, 1) })
    |> result.flatten
    |> result.map_error(fn(_) {
      api_response.err("Invalid authorization header", 401)
    }),
  )

  Ok(token)
}

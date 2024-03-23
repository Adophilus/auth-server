import wisp
import gleam/http.{Post}
import gleam/result.{try}
import gleam/dynamic.{type Dynamic}
import gleam/io
import gleam/string
import gleam/list
import app/database.{type Database}
import app/api_response.{type ApiResponse}
import gleam/http/request

type Body {
  Body(authentication_method: String)
}

fn decode_body(json: Dynamic) -> Result(Body, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode1(
      Body,
      dynamic.field("authentication_method", dynamic.string),
    )

  decoder(json)
}

pub fn add_authentication_method(
  req: wisp.Request,
  db: Database,
) -> wisp.Response {
  use <- wisp.require_method(req, Post)
  use json_body <- wisp.require_json(req)

  // use _token <- try(
  //   check_authentication(req)
  //   |> result.map_error(api_response.to_wisp_response),
  // )

  api_response.ok("Not implmeneted yet", 500)
  |> api_response.to_wisp_response
}

fn check_authentication(req: wisp.Request) -> Result(String, ApiResponse) {
  use token <- try(
    request.get_header(req, "authorization")
    |> result.map(fn(header) { string.split(header, "_") })
    |> result.map(fn(header) { list.at(header, 1) })
    |> result.flatten
    |> result.map_error(fn(_) {
      api_response.err("Invalid authorization header", 401)
    }),
  )

  io.debug(token)

  Ok(token)
}

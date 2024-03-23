import wisp
import gleam/http.{Post}
import gleam/result
import gleam/option
import gleam/dynamic.{type Dynamic}
import gleam/json
import gleam/io
import app/database.{type Database}
import app/api_response
import app/utils

type Body {
  Body(email: String, password: String)
}

fn decode_body(json: Dynamic) -> Result(Body, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode2(
      Body,
      dynamic.field("email", dynamic.string),
      dynamic.field("password", dynamic.string),
    )

  decoder(json)
}

pub fn sign_in(req: wisp.Request, db: Database) -> wisp.Response {
  use <- wisp.require_method(req, Post)
  use json_body <- wisp.require_json(req)

  let res = {
    use body <- result.try(
      decode_body(json_body)
      |> result.map_error(fn(_) {
        api_response.err("Invalid request body", 400)
      }),
    )
    use user <- result.try(
      database.get_user(db, body.email)
      |> result.map(fn(opt) {
        option.to_result(opt, api_response.err("Invalid credentials", 400))
      })
      |> result.flatten,
    )

    case utils.compare_hash(body.password, user.password) {
      True -> {
        let token = utils.generate_token(user)
        Ok(api_response.ok(token, 200))
      }
      False -> Error(api_response.err("Invalid credentials", 400))
    }
  }

  res
  |> result.unwrap_both
  |> api_response.to_wisp_response
}

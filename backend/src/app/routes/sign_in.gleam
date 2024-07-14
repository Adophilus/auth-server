import app/api_response
import app/database
import app/database/user
import app/types
import app/utils
import app/utils/token
import gleam/dynamic.{type Dynamic}
import gleam/http.{Post}
import gleam/io
import gleam/json
import gleam/option.{None, Some}
import gleam/result
import wisp

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

pub fn sign_in(req: wisp.Request, ctx: types.Context) -> wisp.Response {
  use <- wisp.require_method(req, Post)
  use json_body <- wisp.require_json(req)

  let res = {
    use body <- result.try(
      decode_body(json_body)
      |> result.map_error(fn(_) {
        api_response.err("Invalid request body", 400)
      }),
    )

    // TODO: fix this
    case user.fetch_by_id(ctx.db, "") {
      Ok(None) -> api_response.err("Invalid credentials", 400)
      Ok(Some(user)) -> {
        // TODO: fix this as well
        case utils.compare_hash(body.password, user.id) {
          True -> {
            let token = token.generate_access_token(ctx.token, user)
            api_response.ok(token.token, 200)
          }
          False -> api_response.err("Invalid credentials", 400)
        }
      }
      Error(_) -> api_response.err("Failed to find user", 500)
    }
    |> Ok
  }

  res
  |> result.unwrap_both
  |> api_response.to_wisp_response
}

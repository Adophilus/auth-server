import app/api_response
import app/database
import app/database/user
import app/types
import gleam/dynamic.{type Dynamic}
import gleam/http.{Post}
import gleam/io
import gleam/result
import wisp

type Body {
  Body(email: String)
}

fn decode_body(json: Dynamic) -> Result(Body, dynamic.DecodeErrors) {
  let decoder = dynamic.decode1(Body, dynamic.field("email", dynamic.string))

  decoder(json)
}

pub fn sign_up(req: wisp.Request, ctx: types.Context) -> wisp.Response {
  use <- wisp.require_method(req, Post)
  use json_body <- wisp.require_json(req)

  let res = {
    use _saved <- result.try(
      user.create(ctx.db)
      |> result.map_error(fn(err) {
        api_response.err("Failed to create user account", 500)
      }),
    )

    // TODO: notify user about account creation

    Ok(Nil)
  }

  case res {
    Ok(_) ->
      api_response.ok("Sign up successful", 201)
      |> api_response.to_wisp_response
    Error(api_response) -> api_response.to_wisp_response(api_response)
  }
}

import app/api_response
import app/database
import app/database/user
import app/lib/auth
import app/types
import gleam/dynamic.{type Dynamic}
import gleam/http.{Post}
import gleam/io
import gleam/json
import gleam/result
import wisp

type Body {
  Body(email: String, password: String)
}

pub fn sign_up(req: wisp.Request, ctx: types.Context) -> wisp.Response {
  use <- wisp.require_method(req, Post)
  use json_body <- wisp.require_json(req)

  // TODO: notify user about account creation

  {
    use body <- result.try(
      dynamic.decode2(
        Body,
        dynamic.field("email", dynamic.string),
        dynamic.field("password", dynamic.string),
      )(json_body)
      |> result.map_error(fn(_) { api_response.err("Invalid params", 400) }),
    )

    use user <- result.try(
      user.create(ctx.db, user.CreateUserPayload(is_verified: True))
      |> result.map_error(fn(_) {
        api_response.err("Failed to create user account", 500)
      }),
    )
    use _ <- result.try(
      auth.add_method(
        ctx.db,
        auth.EmailPassword,
        user,
        json.object([
          #("email", json.string(body.email)),
          #("password", json.string(body.password)),
        ])
          |> json.to_string,
      )
      |> result.map_error(fn(_) {
        api_response.err("Failed to add authentication method", 500)
      }),
    )
    Ok(api_response.ok("Sign up successful", 201))
  }
  |> result.unwrap_both()
  |> api_response.to_wisp_response
}

pub fn route(
  path: List(String),
  req: wisp.Request,
  ctx: types.Context,
) -> wisp.Response {
  case path {
    ["strategy", "credentials"] -> sign_up(req, ctx)
    _ -> wisp.not_found()
  }
}

import wisp
import gleam/http.{Post}
import gleam/result.{try}
import gleam/dynamic.{type Dynamic}
import gleam/io
import app/database.{type Database}
import app/utils.{send_welcome_email}
import app/api_response

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

pub fn sign_up(req: wisp.Request, db: Database) -> wisp.Response {
  use <- wisp.require_method(req, Post)
  use json_body <- wisp.require_json(req)

  let result = {
    use body <- try(
      decode_body(json_body)
      |> result.map_error(fn(_) {
        api_response.err("Failed to decode JSON", 400)
      }),
    )

    let encrypted_password = utils.hash_password(body.password)

    use _saved <- try(database.save_user(
      db,
      database.User(body.email, encrypted_password),
    ))

    case send_welcome_email(body.email) {
      Ok(_) -> io.println("Sent welcome email to " <> body.email)
      Error(_) -> io.println("Failed to send welcome email to " <> body.email)
    }

    Ok(Nil)
  }

  case result {
    Ok(_) ->
      api_response.ok("Sign up successful", 201)
      |> api_response.to_wisp_response
    Error(api_response) -> api_response.to_wisp_response(api_response)
  }
}

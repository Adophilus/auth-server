import app/middleware.{middleware}
import wisp.{type Request, type Response}
import app/database.{get_db}
import gleam/io
import app/routes/sign_up.{sign_up}
import app/routes/sign_in.{sign_in}
import app/routes/add_authentication_method.{add_authentication_method}

pub fn router(req: Request) -> Response {
  use req <- middleware(req)
  case get_db() {
    Ok(db) ->
      case wisp.path_segments(req) {
        ["sign-up"] -> sign_up(req, db)
        ["sign-in"] -> sign_in(req, db)
        ["method"] -> add_authentication_method(req, db)
        _ -> wisp.not_found()
      }
    Error(_) -> wisp.internal_server_error()
  }
}

import app/middleware.{middleware}
import app/routes/add_method.{add_method}
import app/routes/sign_in.{sign_in}
import app/routes/sign_up.{sign_up}
import app/types
import wisp.{type Request, type Response}

pub fn router(req: Request, ctx: types.Context) -> Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    ["sign-up"] -> sign_up(req, ctx)
    ["sign-in"] -> sign_in(req, ctx)
    ["method"] -> add_method(req, ctx)
    _ -> wisp.not_found()
  }
}

import app/config
import app/context
import app/router.{router}
import gleam/erlang/process
import mist
import wisp

pub fn main() {
  wisp.configure_logger()

  let assert Ok(config) = config.load()
  let assert Ok(ctx) = context.new(config)

  let assert Ok(_) =
    wisp.mist_handler(fn(req) { router(req, ctx) }, config.secret_key)
    |> mist.new()
    |> mist.port(config.port)
    |> mist.start_http

  process.sleep_forever()
}

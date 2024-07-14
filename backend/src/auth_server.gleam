import gleam/erlang/process
import wisp
import app/router.{router}
import mist
import app/config.{get_config}
import dotenv_gleam

pub fn main() {
  dotenv_gleam.config()
  wisp.configure_logger()

  let assert Ok(config) = get_config()

  let assert Ok(_) =
    wisp.mist_handler(router, config.secret_key)
    |> mist.new()
    |> mist.port(config.port)
    |> mist.start_http

  process.sleep_forever()
}

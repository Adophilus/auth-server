import app/types
import gleam/erlang/os
import gleam/int
import gleam/result.{try}

pub fn load() -> Result(types.Config, Nil) {
  use database_url <- try(os.get_env("DATABASE_URL"))
  let database_url = database_url <> "?mode=memory"
  use resend_api_key <- try(os.get_env("RESEND_API_KEY"))
  use raw_port <- try(os.get_env("PORT"))
  use port <- try(int.parse(raw_port))
  use raw_proxy_port <- try(os.get_env("PROXY_PORT"))
  use proxy_port <- try(int.parse(raw_proxy_port))
  use secret_key <- try(os.get_env("SECRET_KEY"))

  Ok(types.Config(database_url, resend_api_key, port, proxy_port, secret_key))
}

import gleam/result.{try}
import gleam/int
import gleam/erlang/os

pub type Config {
  Config(
    database_url: String,
    resend_api_key: String,
    port: Int,
    secret_key: String,
  )
}

pub fn get_config() -> Result(Config, Nil) {
  let config = {
    use database_url <- try(os.get_env("DATABASE_URL"))
    use resend_api_key <- try(os.get_env("RESEND_API_KEY"))
    use raw_port <- try(os.get_env("PORT"))
    use port <- try(int.parse(raw_port))
    use secret_key <- try(os.get_env("SECRET_KEY"))

    Ok(Config(database_url, resend_api_key, port, secret_key))
  }

  config
}

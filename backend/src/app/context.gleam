import app/database
import app/types

pub fn new(config: types.Config) -> Result(types.Context, Nil) {
  let assert Ok(database_connection) = database.connect(config.database_url)

  Ok(types.Context(
    database_connection,
    types.EmailConfig(config.resend_api_key),
    types.TokenConfig(config.secret_key),
  ))
}

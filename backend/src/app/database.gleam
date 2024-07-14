import app/types
import sqlight

pub fn connect(url: String) -> Result(types.DatabaseConnection, Nil) {
  use connection <- sqlight.with_connection(url)
  Ok(types.DatabaseConnection(connection))
}

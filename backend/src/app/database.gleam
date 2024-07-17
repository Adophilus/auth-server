import app/types
import gleam/io
import sqlight

pub type Error {
  ConnectionFailed
}

fn enable_extensions(db: types.DatabaseConnection) {
  let sql =
    "
    PRAGMA foreign_keys = on;
    PRAGMA journal_mode = wal;
    "
  case sqlight.exec(sql, db.connection) {
    Ok(_) -> Nil
    Error(err) -> {
      io.debug("Failed to execute extensions")
      io.debug(err)
      Nil
    }
  }
}

pub fn connect(url: String) -> Result(types.DatabaseConnection, Error) {
  case sqlight.open(url) {
    Ok(connection) -> {
      let connection = types.DatabaseConnection(connection)
      enable_extensions(connection)
      Ok(connection)
    }
    Error(err) -> {
      io.debug("Failed to open connection to database: " <> url)
      io.debug(err)
      Error(ConnectionFailed)
    }
  }
}

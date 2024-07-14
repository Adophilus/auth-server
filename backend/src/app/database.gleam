import gleam/pgo
import gleam/dynamic.{type DecodeError}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import app/config.{get_config}
import gleam/result.{map, try, unwrap}
import app/api_response.{type ApiResponse}

pub type User {
  User(email: String, password: String)
}

pub type DbUser {
  DbUser(id: Int, email: String, password: String)
}

pub type Database {
  Database(connection: pgo.Connection)
}

pub fn get_db() -> Result(Database, Nil) {
  use config <- try(get_config())

  use pgo_config <- try(pgo.url_config(config.database_url))

  let conn = pgo.connect(pgo_config)

  Ok(Database(conn))
}

pub fn save_user(db: Database, user: User) -> Result(Nil, ApiResponse) {
  let sql = "INSERT INTO users (email, password) VALUES ($1, $2)"

  let res =
    pgo.execute(
      sql,
      on: db.connection,
      with: [pgo.text(user.email), pgo.text(user.password)],
      expecting: dynamic.dynamic,
    )

  case res {
    Ok(_) -> Ok(Nil)
    Error(err) -> {
      case err {
        pgo.ConstraintViolated(_, _, _) ->
          Error(api_response.err("User already exists", 409))
        _ -> {
          io.debug(err)
          Error(api_response.err("Failed to save user", 500))
        }
      }
    }
  }
}

pub fn get_user(
  db: Database,
  email: String,
) -> Result(Option(User), ApiResponse) {
  let sql = "SELECT email, password FROM users WHERE email = $1"

  let res =
    pgo.execute(
      sql,
      on: db.connection,
      with: [pgo.text(email)],
      expecting: dynamic.tuple2(dynamic.string, dynamic.string),
    )

  case res {
    Ok(res) ->
      unwrap(
        list.at(res.rows, 0)
          |> map(fn(row) { Some(User(row.0, row.1)) }),
        None,
      )
      |> Ok
    Error(err) -> {
      io.debug(err)
      Error(api_response.err("Failed to get user", 500))
    }
  }
}

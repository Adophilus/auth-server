import app/types
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import ids/ulid
import rada/date
import sqlight

pub type User {
  User(id: String)
}

pub type Error {
  UserAlreadyExists
  UnexpectedError
}

pub fn create(db: types.DatabaseConnection) -> Result(Nil, Error) {
  let query = "INSERT INTO users (email) VALUES ($1)"

  case
    sqlight.query(
      query,
      on: db.connection,
      with: [
        sqlight.text(ulid.generate()),
        sqlight.int(
          date.today()
          |> date.to_rata_die,
        ),
      ],
      expecting: dynamic.dynamic,
    )
  {
    Ok(_) -> Ok(Nil)
    Error(sqlight.SqlightError(sqlight.ConstraintCheck, _, _)) ->
      Error(UserAlreadyExists)
    Error(sqlight.SqlightError(err, _, _)) -> {
      io.debug("Error occurred while running query: " <> query)
      io.debug(err)
      Error(UnexpectedError)
    }
  }
}

pub fn fetch_by_id(
  db: types.DatabaseConnection,
  email: String,
) -> Result(Option(User), Error) {
  let query = "SELECT * FROM users WHERE id = $1"

  case
    sqlight.query(
      query,
      on: db.connection,
      with: [sqlight.text(email)],
      expecting: dynamic.tuple2(dynamic.string, dynamic.string),
    )
  {
    Ok(row) ->
      list.at(row, 0)
      |> result.map(fn(row) { Some(User(row.0)) })
      |> result.unwrap(None)
      |> Ok
    Error(err) -> {
      io.debug("Error occurred while running query: " <> query)
      io.debug(err)
      Error(UnexpectedError)
    }
  }
}

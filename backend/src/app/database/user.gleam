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
  UserNotFound
}

pub type CreateUserPayload {
  CreateUserPayload(is_verified: Bool)
}

pub fn create(
  db: types.DatabaseConnection,
  payload: CreateUserPayload,
) -> Result(User, Error) {
  let query =
    "INSERT INTO users (id, is_verified, created_at) VALUES ($1, $2, $3) RETURNING id, ''"

  case
    sqlight.query(
      query,
      on: db.connection,
      with: [
        sqlight.text(ulid.generate()),
        sqlight.bool(payload.is_verified),
        sqlight.int(
          date.today()
          |> date.to_rata_die,
        ),
      ],
      expecting: dynamic.tuple2(dynamic.string, dynamic.string),
    )
  {
    Ok([]) -> Error(UserNotFound)
    Ok([row, ..]) -> {
      Ok(User(id: row.0))
    }
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
  let query = "SELECT id, '' FROM users WHERE id = $1"

  case
    sqlight.query(
      query,
      on: db.connection,
      with: [sqlight.text(email)],
      expecting: dynamic.tuple2(dynamic.string, dynamic.string),
    )
  {
    Ok([]) -> Ok(None)
    Ok([row, ..]) -> Ok(Some(User(id: row.0)))
    Error(err) -> {
      io.debug("Error occurred while running query: " <> query)
      io.debug(err)
      Error(UnexpectedError)
    }
  }
}

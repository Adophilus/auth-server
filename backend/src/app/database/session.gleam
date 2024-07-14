import app/database/user.{type User}
import app/types
import gleam/dynamic
import gleam/io
import ids/ulid
import rada/date.{type Date}
import sqlight

pub type Session {
  Session(id: String, user_id: String, expires_at: Int)
}

pub type Error {
  UnexpectedError
}

pub fn create(
  db: types.DatabaseConnection,
  user: User,
  expires_at: Date,
) -> Result(Nil, Error) {
  let query = "INSERT INTO sessions (id, user_id, expires_at, created_at)"

  case
    sqlight.query(
      query,
      on: db.connection,
      with: [
        sqlight.text(ulid.generate()),
        sqlight.text(user.id),
        sqlight.int(
          expires_at
          |> date.to_rata_die,
        ),
      ],
      expecting: dynamic.dynamic,
    )
  {
    Ok(_) -> Ok(Nil)
    Error(err) -> {
      io.debug("Error occurred while running query: " <> query)
      io.debug(err)
      Error(UnexpectedError)
    }
  }
}

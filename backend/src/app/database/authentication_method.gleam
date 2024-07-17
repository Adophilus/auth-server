import app/types
import gleam/dynamic
import gleam/io
import ids/ulid
import rada/date
import sqlight

pub type AuthenticationMethodProvider {
  EmailPassword
  // UsernamePassword
  // EmailMagicLink
  // EmailOtp
  // Passkey
}

pub type AuthenticationMethod {
  AuthenticationMethod(
    id: String,
    provider: AuthenticationMethodProvider,
    uid: String,
    metadata: String,
  )
}

fn serialize_provider(provider: AuthenticationMethodProvider) -> String {
  case provider {
    EmailPassword -> "EMAIL_PASSWORD"
  }
}

fn deserialize_provider(provider: String) -> AuthenticationMethodProvider {
  case provider {
    "EMAIL_PASSWORD" -> EmailPassword
    _ -> panic("UNEXPECTED_DATABASE_PROVIDER")
  }
}

pub type CreateAuthenticationMethod {
  CreateAuthenticationMethod(
    uid: String,
    provider: AuthenticationMethodProvider,
    metadata: String,
  )
}

pub type Error {
  UnexpectedError
}

pub fn create(
  db: types.DatabaseConnection,
  payload: CreateAuthenticationMethod,
) -> Result(AuthenticationMethod, Error) {
  let query =
    "INSERT INTO authentication_methods (id, provider, uid, metadata, created_at) VALUES ($1, $2, $3, $4, $5) RETURNING id, provider, uid, metadata"

  case
    sqlight.query(
      query,
      on: db.connection,
      with: [
        sqlight.text(ulid.generate()),
        sqlight.text(serialize_provider(payload.provider)),
        sqlight.text(payload.uid),
        sqlight.text(payload.metadata),
        sqlight.int(
          date.today()
          |> date.to_rata_die,
        ),
      ],
      expecting: dynamic.tuple4(
        dynamic.string,
        dynamic.string,
        dynamic.string,
        dynamic.string,
      ),
    )
  {
    Ok([]) -> Error(UnexpectedError)
    Ok([row, ..]) ->
      Ok(AuthenticationMethod(
        id: row.0,
        provider: deserialize_provider(row.1),
        uid: row.2,
        metadata: row.3,
      ))
    Error(sqlight.SqlightError(err, _, _)) -> {
      io.debug("Error occurred while running query: " <> query)
      io.debug(err)
      Error(UnexpectedError)
    }
  }
}

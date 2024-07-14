import app/database/user.{type User}
import app/types
import gleam/bit_array
import gleam/crypto
import gleam/dynamic
import gleam/json
import gleam/result

pub type AccessToken {
  AccessToken(id: String, token: String)
}

type AccessTokenInner {
  AccessTokenInner(id: String)
}

pub fn generate_access_token(cfg: types.TokenConfig, user: User) -> AccessToken {
  let token =
    cfg.secret_key
    |> bit_array.from_string
    |> crypto.sign_message(
      json.object([#("id", json.string(user.id))])
        |> json.to_string
        |> bit_array.from_string,
      _,
      crypto.Sha512,
    )

  AccessToken(user.id, token)
}

pub fn to_access_token(
  cfg: types.TokenConfig,
  token: String,
) -> Result(AccessToken, Nil) {
  use payload <- result.try(
    token
    |> crypto.verify_signed_message(
      cfg.secret_key
      |> bit_array.from_string,
    )
    |> result.map(fn(ba) {
      ba
      |> bit_array.to_string
    })
    |> result.flatten
    |> result.map_error(fn(_) { Nil }),
  )

  case
    json.decode(
      payload,
      dynamic.decode1(AccessTokenInner, dynamic.field("id", dynamic.string)),
    )
  {
    Error(_) -> Error(Nil)
    Ok(access_token) -> Ok(AccessToken(id: access_token.id, token: payload))
  }
}

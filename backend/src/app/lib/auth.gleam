import app/database/authentication_method
import app/database/user
import app/types

pub type AuthenticationMethod {
  EmailPassword
  // UsernamePassword
  // EmailMagicLink
  // EmailOtp
  // Passkey
}

fn authentication_method_to_provider(
  method: AuthenticationMethod,
) -> authentication_method.AuthenticationMethodProvider {
  case method {
    EmailPassword -> authentication_method.EmailPassword
  }
}

pub fn add_method(
  db: types.DatabaseConnection,
  method: AuthenticationMethod,
  user: user.User,
  metadata: String,
) {
  let authentication_method_provider = authentication_method_to_provider(method)
  authentication_method.create(
    db,
    authentication_method.CreateAuthenticationMethod(
      user.id,
      authentication_method_provider,
      metadata,
    ),
  )
}

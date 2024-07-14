import sqlight

pub type Config {
  Config(
    database_url: String,
    resend_api_key: String,
    port: Int,
    proxy_port: Int,
    secret_key: String,
  )
}

pub type DatabaseConnection {
  DatabaseConnection(connection: sqlight.Connection)
}

pub type EmailConfig {
  EmailConfig(api_key: String)
}

pub type TokenConfig {
  TokenConfig(secret_key: String)
}

pub type Context {
  Context(db: DatabaseConnection, email: EmailConfig, token: TokenConfig)
}

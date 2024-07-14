CREATE TABLE authentication_methods (
  id SERIAL PRIMARY KEY NOT NULL,
  provider VARCHAR NOT NULL,
  uid VARCHAR NOT NULL,
  metadata VARCHAR,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP
);

import wisp
import gleam/json

pub type ApiResponse {
  Ok(message: String, status: Int)
  Error(message: String, status: Int)
}

pub fn to_wisp_response(api_response: ApiResponse) -> wisp.Response {
  case api_response {
    Ok(msg, status) ->
      json.object([
        #("message", json.string(msg)),
        #("status", json.int(status)),
      ])
      |> json.to_string_builder
      |> wisp.json_response(status)
    Error(msg, status) ->
      json.object([
        #("message", json.string(msg)),
        #("status", json.int(status)),
      ])
      |> json.to_string_builder
      |> wisp.json_response(status)
  }
}

pub fn ok(message: String, status: Int) -> ApiResponse {
  Ok(message, status)
}

pub fn err(message: String, status: Int) -> ApiResponse {
  Error(message, status)
}

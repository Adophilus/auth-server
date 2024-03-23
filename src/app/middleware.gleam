import wisp

pub fn middleware(
  req: wisp.Request,
  request_handler: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes

  request_handler(req)
}

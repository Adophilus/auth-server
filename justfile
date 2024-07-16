backend-dev: 
  cd backend && air

proxy:
  mitmproxy --listen-port $PROXY_PORT --mode reverse:http://127.0.0.1:$PORT

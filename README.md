# Exi

## How to run locally

Ngrok must be running for Telegram calling in:

    ngrok http 4000 -subdomain=exi

### Docker

    docker run -e PHX_SERVER=true -e SECRET_KEY_BASE=Mp7fEBRFRWeh1KXPzxTsvjFlVWIK9zIpRSRklaMdiN5k4M/MUlasj9ZrSo9BmEYG -e DATABASE_URL=ecto://postgres:postgres@host.docker.internal/exi_dev -p 4000:4000 elixir/exi

# Exi

## How to run locally

Ngrok must be running for Telegram calling in:

    ngrok http 4000 -subdomain=exi

### Docker

    docker run -e PHX_SERVER=true -e SECRET_KEY_BASE=Mp7fEBRFRWeh1KXPzxTsvjFlVWIK9zIpRSRklaMdiN5k4M/MUlasj9ZrSo9BmEYG -e DATABASE_URL=ecto://postgres:postgres@host.docker.internal/exi_dev -p 4000:4000 elixir/exi

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

defmodule Exi.Repo do
  use Ecto.Repo,
    otp_app: :exi,
    adapter: Ecto.Adapters.Postgres
end

defmodule ExiWeb.HealthcheckController do
  use ExiWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      name: "exi",
      release_sha: Application.get_env(:exi, :release_sha)
    })
  end
end

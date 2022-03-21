defmodule Exi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Exi.Repo,
      # Start the Telemetry supervisor
      ExiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Exi.PubSub},
      # Start the Endpoint (http/https)
      ExiWeb.Endpoint
      # Start a worker by calling: Exi.Worker.start_link(arg)
      # {Exi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule ExiWeb.TelegramBotController do
  use ExiWeb, :controller
  alias Exi.Telegram.Parser

  def callback(conn, params) do
    Parser.parse(params)

    json(conn, %{status: "ok"})
  end
end

defmodule Exi.TelegramBot.Client do
  require Logger

  def config do
    Application.get_env(:exi, :telegram_bot)
  end

  def new() do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://api.telegram.org/bot#{config()[:token]}"},
      Tesla.Middleware.JSON
    ])
  end

  def post(client, method, params) do
    client
    |> Tesla.post(method, params)
    |> case do
      {:ok, %{:body => %{"ok" => true}}} ->
        :ok

      {:ok, %{:body => %{"ok" => false, "description" => description, "error_code" => 403}}} ->
        {:blocked, description}

      {:ok,
       %{:body => %{"ok" => false, "description" => description, "error_code" => error_code}}} ->
        Logger.error("TelegramBot.Client: #{error_code}. #{description}.")
        {:error, description}

      e ->
        msg = "TelegramBot.Client: #{inspect(e)}"
        Logger.error(msg)
        {:error, msg}
    end
  end

  def send_message(params) do
    new()
    |> __MODULE__.post("sendMessage", params)
  end

  def send_photo(params) do
    new()
    |> __MODULE__.post("sendPhoto", params)
  end
end

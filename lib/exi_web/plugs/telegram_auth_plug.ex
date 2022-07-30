defmodule ExiWeb.TelegramAuthPlug do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _) do
    with {:ok, %{"user" => user}} <-
           validate_web_app_init_data(
             conn.params,
             Application.get_env(:exi, :telegram_bot)[:token]
           ),
         {:ok, user} <- JSON.decode(user) do
      conn
      |> put_session("telegram_user", user)
      |> put_session("query_string", conn.query_string)
    else
      _ ->
        conn
    end
  end

  def validate_web_app_init_data(tg_init_data, bot_api_token) do
    {received_hash, decoded_map} =
      tg_init_data
      # |> URI.decode_query()
      |> Map.pop("hash")

    data_check_string =
      decoded_map
      |> Enum.sort(fn {k1, _v1}, {k2, _v2} -> k1 <= k2 end)
      |> Enum.map_join("\n", fn {k, v} -> "#{k}=#{v}" end)

    calculated_hash =
      "WebAppData"
      |> hmac(bot_api_token)
      |> hmac(data_check_string)
      |> Base.encode16(case: :lower)

    if received_hash == calculated_hash do
      {:ok, decoded_map}
    else
      :error
    end
  end

  def hmac(key, data) do
    :crypto.mac(:hmac, :sha256, key, data)
  end
end

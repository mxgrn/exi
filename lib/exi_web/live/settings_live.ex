defmodule ExiWeb.WebApp.SettingsLive do
  use ExiWeb, :live_view
  use Phoenix.HTML

  alias Exi.Telegram

  def mount(_params, _session, socket) do
    case socket.assigns do
      %{telegram_user: telegram_user} ->
        user = Telegram.get_user(telegram_user, [:groups])
        {:ok, assign(socket, %{groups: user.groups, href: nil, user: user})}

      _ ->
        {:ok, socket}
    end
  end

  def validate_web_app_init_data(tg_init_data, bot_api_token) do
    {received_hash, decoded_map} =
      tg_init_data
      |> URI.decode_query()
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

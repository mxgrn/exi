defmodule ExiWeb.WebApp.GroupSettingsLive do
  use ExiWeb, :live_view
  alias Exi.Telegram
  alias Exi.Groups

  def mount(%{"id" => id}, _session, socket) do
    user = Telegram.get_user(socket.assigns.telegram_user, [:groups])
    group = Groups.get(id, [:users])

    {:ok, assign(socket, %{group: group, user: user})}
  end
end

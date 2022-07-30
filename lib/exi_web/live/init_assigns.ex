defmodule ExiWeb.InitAssigns do
  def on_mount(
        :default,
        _params,
        %{"telegram_user" => telegram_user, "query_string" => query_string},
        socket
      ) do
    {:cont,
     Phoenix.LiveView.assign(socket, %{telegram_user: telegram_user, query_string: query_string})}
  end

  def on_mount(_, _, _, socket) do
    {:cont, socket}
  end
end

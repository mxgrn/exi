defmodule ExiWeb.WebApp.SettingsLive do
  use ExiWeb, :live_view

  alias Exi.Telegram
  alias Exi.Groups

  def mount(_params, _session, socket) do
    with %{"tg_init_data" => data} <- get_connect_params(socket),
         {:ok, %{"user" => user}} <-
           validate_web_app_init_data(data, Application.get_env(:exi, :telegram_bot)[:token]),
         {:ok, user} <- JSON.decode(user) do
      user = Telegram.get_user(user, [:groups])
      {:ok, assign(socket, :groups, user.groups)}
    else
      _ ->
        {:ok, assign(socket, :groups, [])}
    end
  end

  def handle_event("open-group", %{"id" => id}, socket) do
    group = Groups.get(id, [:users])

    {:noreply, assign(socket, :group, group)}
  end

  def render(%{group: _group} = assigns) do
    ~H"""
    <div class="text-xl text-center">
      <%= @group.telegram_title %>
    </div>

    <ul class="space-y-1">
      <%= for user <- @group.users do %>
        <li>
          <a class="pl-4-safe flex items-center  duration-300 active:duration-0 cursor-pointer select-none active:hairline-transparent active:bg-black active:bg-opacity-10 dark:active:bg-white dark:active:bg-opacity-10">
            <div class="pr-4-safe w-full relative hairline-b py-2.5">
              <div class="flex justify-between items-center  text-list-title-ios">
                <div class="shrink">
                  <%= user.username %>
                </div>
              </div>
            </div>
          </a>
        </li>
      <% end %>
    </ul>
    """
  end

  def render(%{groups: _groups} = assigns) do
    ~H"""
    <h3 class="text-xl text-center">Your groups</h3>
    <ul class="last-child-hairline-b-none">
      <%= for group <- @groups do %>
        <li>
          <a
            class="pl-4-safe flex items-center  duration-300 active:duration-0 cursor-pointer select-none active:hairline-transparent active:bg-black active:bg-opacity-10 dark:active:bg-white dark:active:bg-opacity-10"
            phx-click="open-group"
            phx-value-id={group.id}
          >
            <div class="pr-4-safe w-full relative hairline-b py-2.5">
              <div class="flex justify-between items-center  text-list-title-ios">
                <div class="shrink">
                  <%= if group.telegram_title do %>
                    <%= group.telegram_title %>
                  <% else %>
                    <i>Unknown (rename group to fix)</i>
                  <% end %>
                </div>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="8"
                  height="14"
                  viewBox="0 0 12 20"
                  fill="currentcolor"
                  class="opacity-20 shrink-0 ml-3"
                >
                  <path d="M11.518406,10.5648622 C11.4831857,10.6163453 11.4426714,10.6653692 11.3968592,10.7111814 L2.5584348,19.5496058 C1.9753444,20.1326962 1.03186648,20.1345946 0.44199608,19.5447242 C-0.14379032,18.9589377 -0.14922592,18.0146258 0.43711448,17.4282854 L7.87507783,9.9903221 L0.4431923,2.5584366 C-0.1398981,1.9753462 -0.1417965,1.0318683 0.448074,0.4419979 C1.0338604,-0.1437886 1.9781723,-0.1492241 2.56451268,0.4371163 L11.4029371,9.2755407 C11.7556117,9.6282153 11.7969345,10.1725307 11.518406,10.5648622 Z">
                  </path>
                </svg>
              </div>
            </div>
          </a>
        </li>
      <% end %>
    </ul>
    """
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

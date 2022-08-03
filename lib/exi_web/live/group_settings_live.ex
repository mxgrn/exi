defmodule ExiWeb.WebApp.GroupSettingsLive do
  use ExiWeb, :live_view
  alias Exi.Telegram
  alias Exi.Groups
  alias Exi.DailySummaryWorker

  @update_delay 1000

  def mount(%{"id" => id}, _session, socket) do
    user = Telegram.get_user(socket.assigns.telegram_user, [:groups])
    group = Groups.get(id, [:users])

    changeset = Groups.change(group)

    {:ok, assign(socket, %{group: group, user: user, changeset: changeset})}
  end

  def handle_event("save", %{"group" => params}, socket) do
    if socket.assigns[:update_timer] do
      Process.cancel_timer(socket.assigns.update_timer)
    end

    timer = Process.send_after(self(), {:update, params}, @update_delay)

    {:noreply, assign(socket, update_timer: timer)}
  end

  def handle_info({:update, params}, socket) do
    case Groups.update(socket.assigns.group, params) do
      {:ok, group} ->
        DailySummaryWorker.reschedule_for_group(group)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def truncate_to_minutes(time) do
    [hours, mins | _] = time |> to_string() |> String.split(":")
    Enum.join([hours, mins], ":")
  end
end

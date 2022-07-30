defmodule ExiWeb.WebApp.GroupSettingsLive do
  use ExiWeb, :live_view
  alias Exi.Telegram
  alias Exi.Groups
  alias Exi.DailySummaryWorker

  def mount(%{"id" => id}, _session, socket) do
    user = Telegram.get_user(socket.assigns.telegram_user, [:groups])
    group = Groups.get(id, [:users])

    changeset = Groups.change(group)

    {:ok, assign(socket, %{group: group, user: user, changeset: changeset})}
  end

  def handle_event("save", %{"group" => params}, socket) do
    update(socket, params)
  end

  def truncate_to_minutes(time) do
    [hours, mins | _] = time |> to_string() |> String.split(":")
    Enum.join([hours, mins], ":")
  end

  defp update(socket, params) do
    case Groups.update(socket.assigns.group, params) do
      {:ok, group} ->
        %{group_id: group.id}
        |> DailySummaryWorker.new(scheduled_at: group.day_end_time, replace: [:scheduled_at])
        |> Oban.insert!()

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

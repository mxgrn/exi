defmodule Exi.DailySummaryWorker do
  use Oban.Worker,
    unique: [period: 60 * 60 * 24 * 365, states: [:scheduled]]

  alias Exi.Repo
  alias Exi.Telegram.Api.Client
  alias Exi.Groups.GroupUser
  alias Exi.Logbook
  alias Exi.Groups
  alias Exi.Entries.Entry

  import Ecto.Query

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"group_id" => group_id}}) do
    group = Groups.get(group_id)

    if Logbook.entry_number_in_group(group) > 0 do
      do_send_summary_to_group(group)
    end

    reschedule_for_group(group)

    :ok
  end

  def reschedule_for_all_groups do
    Groups.list()
    |> Enum.each(&reschedule_for_group/1)
  end

  def reschedule_for_group(%{id: group_id}) do
    group = Groups.get(group_id)

    %{group_id: group_id}
    |> new(scheduled_at: Groups.next_daily_report_at(group), replace: [:scheduled_at])
    |> Oban.insert()
  end

  def send_summary_to_group(group) do
    if Logbook.entry_number_in_group(group) > 0 do
      do_send_summary_to_group(group)
    end
  end

  def summary_for_group(group) do
    group
    |> Repo.preload(:users)
    |> Map.get(:users)
    |> Enum.map(&summary_for_user(&1, group))
    |> Enum.sort_by(fn {_username, sum} -> -sum end)
    |> Enum.with_index()
    |> Enum.map(&user_scoreboard_line/1)
    |> Enum.join("\n")
  end

  defp summary_for_user(%{id: user_id, username: username}, %{id: group_id}) do
    group = Groups.get(group_id)
    group_user = Repo.get_by(GroupUser, user_id: user_id, group_id: group_id)

    sum =
      from(e in Entry,
        where:
          e.group_user_id == ^group_user.id and
            e.inserted_at >= ^Groups.last_daily_report_at(group)
      )
      |> Repo.aggregate(:sum, :amount) || 0

    {username, sum}
  end

  defp user_scoreboard_line({{username, sum}, i}) do
    medal = %{0 => "🥇", 1 => "🥈", 2 => "🥉"}
    "#{medal[i] && "#{medal[i]} "}#{username}: #{sum}"
  end

  defp do_send_summary_to_group(group) do
    summary = """
    Summary for today
    #{summary_for_group(group)}
    """

    Client.send_message(%{text: summary, chat_id: group.telegram_id})
  end
end

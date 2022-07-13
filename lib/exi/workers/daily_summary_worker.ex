defmodule Exi.DailySummaryWorker do
  use Oban.Worker, queue: :events

  alias Exi.Repo
  alias Exi.TelegramBot.Client
  alias Exi.Telegram
  alias Exi.Schemas.GroupUser
  alias Exi.Logbook.Entry

  import Ecto.Query

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args}) do
    send_out_summaries()

    :ok
  end

  def send_out_summaries() do
    Telegram.list_groups()
    |> Enum.each(&send_summary_to_group/1)
  end

  def send_summary_to_group(group) do
    summary = """
    Summary for today:
    #{summary_for_group(group)}
    """

    Client.send_message(%{text: summary, chat_id: group.telegram_id})
  end

  defp summary_for_group(group) do
    group.users
    |> Enum.map(&summary_for_user(&1, group))
    |> Enum.join("\n")
  end

  defp summary_for_user(%{id: user_id, username: username}, %{id: group_id}) do
    group_user = Repo.get_by(GroupUser, user_id: user_id, group_id: group_id)
    now = DateTime.utc_now()
    beginning_of_day = %{now | hour: 0, minute: 0, second: 0, microsecond: {0, 0}}

    sum =
      from(e in Entry,
        where:
          e.group_user_id == ^group_user.id and
            e.inserted_at < ^now and
            e.inserted_at > ^beginning_of_day
      )
      |> Repo.aggregate(:sum, :amount) || 0

    "#{username}: #{sum}"
  end
end

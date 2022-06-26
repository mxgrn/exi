defmodule Exi.EntryReminder do
  use Oban.Worker, queue: :events

  alias Exi.TelegramBot.Client
  alias Exi.Telegram

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"group_id" => group_id}}) do
    group = Telegram.get_group(group_id)

    Client.send_message(%{text: "How has your hour been (0-9)?", chat_id: group.telegram_id})

    Telegram.schedule_hourly_reminders(group)

    :ok
  end
end
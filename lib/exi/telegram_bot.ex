defmodule Exi.TelegramBot do
  alias Exi.Telegram
  alias Exi.Logbook

  @bot_id 5_222_232_628

  def parse_callback!(data), do: parse_callback(data)

  defp parse_callback(%{
         "message" => %{
           "new_chat_member" => %{"id" => @bot_id},
           "chat" => group_data
         }
       }) do
    Telegram.ensure_group(group_data)
  end

  defp parse_callback(%{
         "message" => %{
           "new_chat_member" => user_data,
           "chat" => group_data
         }
       }) do
    group = Telegram.ensure_group(group_data)
    Telegram.ensure_user_in_group(user_data, group)
  end

  defp parse_callback(%{
         "message" => %{
           "chat" => group_data,
           "from" => user_data,
           "text" => text
         }
       }) do
    log_entry(text, user_data, group_data)
  end

  defp parse_callback(data) do
    IO.puts(~s(\nUnknown data: #{inspect(data)}\n))
  end

  def log_entry(text, user_data, group_data) do
    group = Telegram.ensure_group(group_data)
    %{group_user: group_user} = Telegram.ensure_user_in_group(user_data, group)

    parse_entry(text)
    |> case do
      {:ok, amount} ->
        Logbook.create_entry(%{amount: amount, group_user_id: group_user.id})

      _ ->
        IO.puts(~s(Can't parse entry: #{inspect(text)}\n))
    end
  end

  defp parse_entry(text) do
    Logbook.parse_amount(text)
  end
end

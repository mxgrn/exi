defmodule Exi.TelegramBot do
  alias Exi.Telegram

  @bot_id 5_222_232_628

  def parse_callback!(data), do: parse_callback(data)

  defp parse_callback(%{
         "message" => %{
           "new_chat_member" => %{"id" => @bot_id},
           "chat" => group_data
         }
       }) do
    Telegram.upsert_group(group_data)
  end

  defp parse_callback(%{
         "message" => %{
           "new_chat_member" => user_data,
           "chat" => group_data
         }
       }) do
    Telegram.upsert_user_and_add_to_group(user_data, group_data)
  end

  defp parse_callback(data) do
    IO.puts(~s(\nUnknown data: #{inspect(data)}\n))
  end
end

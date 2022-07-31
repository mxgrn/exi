defmodule Exi.TelegramBot do
  alias Exi.Telegram

  @bot_id Application.get_env(:exi, :telegram)[:bot_id] ||
            raise("Please, configure Telegram bot ID")

  def parse_callback!(data) do
    parse_callback(data)
    :ok
  end

  # bot gets kicked out of a group
  defp parse_callback(%{
         "message" => %{
           "left_chat_member" => %{
             "is_bot" => true
           },
           "chat" => group_data
         }
       }) do
    Telegram.delete_group(group_data)
  end

  # bot gets added to a group
  defp parse_callback(%{
         "my_chat_member" => %{
           "new_chat_member" => %{"user" => %{"id" => @bot_id, "is_bot" => true}},
           "chat" => group_data
         }
       }) do
    Telegram.ensure_group(group_data)
  end

  # regular message, maybe an entry
  defp parse_callback(%{
         "message" => %{
           "chat" => group_data,
           "from" => user_data,
           "text" => text,
           "message_id" => message_id
         }
       }) do
    Telegram.log_entry(text, user_data, group_data, message_id)
  end

  # user edits a message
  defp parse_callback(%{
         "edited_message" => %{
           "chat" => group_data,
           "from" => user_data,
           "text" => text,
           "message_id" => message_id
         }
       }) do
    Telegram.edit_entry(text, user_data, group_data, message_id)
  end

  # group gets renamed by admin
  defp parse_callback(%{
         "message" => %{
           "chat" => group_data,
           "new_chat_title" => new_group_name
         }
       }) do
    Telegram.rename_group(group_data, new_group_name)
  end

  # follback
  defp parse_callback(data) do
    IO.puts(~s(\nUnknown data: #{inspect(data)}\n))
  end
end

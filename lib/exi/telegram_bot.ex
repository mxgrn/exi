defmodule Exi.TelegramBot do
  alias Exi.Telegram
  alias Exi.Logbook

  @bot_id 5_222_232_628

  def parse_callback!(data), do: parse_callback(data)

  # bot kicked out of the group
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
           "text" => text,
           "message_id" => message_id
         }
       }) do
    log_entry(text, user_data, group_data, message_id)
  end

  defp parse_callback(%{
         "edited_message" => %{
           "chat" => group_data,
           "from" => user_data,
           "text" => text,
           "message_id" => message_id
         }
       }) do
    edit_entry(text, user_data, group_data, message_id)
  end

  defp parse_callback(data) do
    IO.puts(~s(\nUnknown data: #{inspect(data)}\n))
  end

  def log_entry(text, user_data, group_data, message_id) do
    parse_entry(text)
    |> case do
      {:ok, amount} ->
        create_entry(amount, user_data, group_data, message_id)

      _ ->
        nil
    end
  end

  def edit_entry(text, user_data, group_data, message_id) do
    # group = Telegram.ensure_group(group_data)
    Logbook.get_by(%{telegram_message_id: message_id}, group_user: [:group, :user])
    |> case do
      nil ->
        parse_entry(text)
        |> case do
          {:ok, amount} ->
            # create entry, possibly for the first time
            create_entry(amount, user_data, group_data, message_id)

          _ ->
            nil
        end

      entry ->
        parse_entry(text)
        |> case do
          {:ok, amount} ->
            Logbook.update_entry(entry, %{amount: amount})

          _ ->
            Logbook.delete_entry!(entry)
        end
    end
  end

  defp parse_entry(text) do
    Logbook.parse_amount(text)
  end

  defp create_entry(amount, user_data, group_data, message_id) do
    group = Telegram.ensure_group(group_data)
    %{group_user: group_user} = Telegram.ensure_user_in_group(user_data, group)

    Logbook.create_entry(%{
      amount: amount,
      group_user_id: group_user.id,
      telegram_message_id: message_id
    })
  end
end

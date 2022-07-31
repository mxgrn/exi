defmodule Exi.Telegram.Parser do
  alias Exi.Telegram

  @bot_id Application.get_env(:exi, :telegram)[:bot_id] ||
            raise("Please, configure Telegram bot ID")

  require Logger

  def parse(%{
        "message" => %{
          "left_chat_member" => %{
            "is_bot" => true
          },
          "chat" => group_data
        }
      }) do
    Logger.info("Bot gets kicked out of a group")
    Telegram.delete_group(group_data)
  end

  def parse(%{
        "my_chat_member" => %{
          "new_chat_member" => %{
            "status" => "kicked",
            "user" => %{"id" => @bot_id, "is_bot" => true}
          },
          "chat" => group_data
        }
      }) do
    Logger.info("User stops the bot")
    Telegram.delete_group(group_data)
  end

  # NOOP
  def parse(%{
        "my_chat_member" => %{
          "new_chat_member" => %{
            "user" => %{"id" => @bot_id, "is_bot" => true}
          },
          "chat" => %{"type" => "private"} = _group_data
        }
      }) do
    Logger.info("Bot gets started by a user")
  end

  def parse(%{
        "my_chat_member" => %{
          "new_chat_member" => %{
            "user" => %{"id" => @bot_id, "is_bot" => true}
          },
          "chat" => group_data
        }
      }) do
    Logger.info("Bot gets added to a group")
    Telegram.ensure_group(group_data)
  end

  # NOOP
  def parse(%{
        "message" => %{
          "chat" => %{"type" => "private"} = _group_data
        }
      }) do
    Logger.info("User sends a message to the bot")
  end

  def parse(%{
        "message" => %{
          "chat" => group_data,
          "from" => user_data,
          "text" => text,
          "message_id" => message_id
        }
      }) do
    Logger.info("User sends a message")
    Telegram.log_entry(text, user_data, group_data, message_id)
  end

  def parse(%{
        "edited_message" => %{
          "chat" => group_data,
          "from" => user_data,
          "text" => text,
          "message_id" => message_id
        }
      }) do
    Logger.info("User edits a message")
    Telegram.edit_entry(text, user_data, group_data, message_id)
  end

  def parse(%{
        "message" => %{
          "chat" => group_data,
          "new_chat_title" => new_group_name
        }
      }) do
    Logger.info("Groups gets renamed by an admin")
    Telegram.rename_group(group_data, new_group_name)
  end

  def parse(_data) do
    Logger.info("Unknown data format")
  end
end

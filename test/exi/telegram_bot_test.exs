defmodule Exi.TelegramBotTest do
  use Exi.DataCase

  alias Exi.TelegramBot
  alias Exi.Repo
  alias Exi.Logbook.Entry
  alias Exi.Schemas.Group
  alias Exi.Schemas.GroupUser
  alias Exi.Schemas.User

  describe "creating message" do
    test "stores entry when message is valid entry" do
      TelegramBot.parse_callback!(message())

      assert Repo.one(Entry)
    end
  end

  describe "editing message" do
    test "changes entry value if entry already existed" do
      %{value: 1, message_id: 1} |> message() |> TelegramBot.parse_callback!()
      entry = Repo.one(Entry)
      assert entry.amount == 1

      %{value: 2, message_id: 1} |> edited_message() |> TelegramBot.parse_callback!()
      entry = reload(entry)
      assert entry.amount == 2
    end

    test "creates entry when random text was replaced with a value" do
      %{value: 1, message_id: 1} |> edited_message() |> TelegramBot.parse_callback!()
      entry = Repo.one(Entry)
      assert entry.amount == 1
    end

    test "deletes entry when existing entry was replaced with random text" do
      %{value: 1, message_id: 1} |> message() |> TelegramBot.parse_callback!()
      assert Repo.one(Entry)

      %{value: "Hello group!", message_id: 1} |> edited_message() |> TelegramBot.parse_callback!()
      refute Repo.one(Entry)
    end
  end

  describe "kicking bot out of group" do
    test "deletes the group and all its associated resources" do
      # create all resources, including a group
      TelegramBot.parse_callback!(message())
      assert Repo.one(User)
      assert Repo.one(GroupUser)
      assert Repo.one(Entry)

      group = Repo.one(Group)
      assert group

      TelegramBot.parse_callback!(bot_removed_message(%{chat_id: group.telegram_id}))

      refute Repo.one(Group)
      refute Repo.one(GroupUser)
      refute Repo.one(Entry)
    end
  end

  defp message(attrs \\ %{}) do
    %{
      "message" => %{
        "chat" => %{"id" => -1_001_712_912_115, "title" => "Exi Days", "type" => "supergroup"},
        "date" => 1_648_282_720,
        "from" => %{
          "first_name" => "Max",
          "id" => 2_144_377,
          "is_bot" => false,
          "language_code" => "en",
          "last_name" => "Grin",
          "username" => "mxgrn"
        },
        "message_id" => attrs[:message_id] || 1,
        "text" => "#{attrs[:value] || 10}"
      },
      "update_id" => 859_434_146
    }
  end

  defp edited_message(attrs) do
    %{
      "edited_message" => %{
        "chat" => %{"id" => -1_001_712_912_115, "title" => "Exi Days", "type" => "supergroup"},
        "date" => 1_648_282_720,
        "edit_date" => 1_657_908_700,
        "from" => %{
          "first_name" => "Max",
          "id" => 2_144_377,
          "is_bot" => false,
          "is_premium" => true,
          "language_code" => "en",
          "last_name" => "Grin",
          "username" => "mxgrn"
        },
        "message_id" => attrs[:message_id] || 1,
        "text" => "#{attrs[:value] || 10}"
      },
      "update_id" => 764_803_799
    }
  end

  defp bot_removed_message(attrs) do
    %{
      "message" => %{
        "chat" => %{
          "all_members_are_administrators" => true,
          "id" => attrs[:chat_id] || -777_618_884,
          "title" => "Exi Dev 1",
          "type" => "group"
        },
        "date" => 1_658_061_989,
        "from" => %{
          "first_name" => "Max",
          "id" => 2_144_377,
          "is_bot" => false,
          "is_premium" => true,
          "language_code" => "en",
          "last_name" => "Grin",
          "username" => "mxgrn"
        },
        "left_chat_member" => %{
          "first_name" => "Exi Dev Bot",
          "id" => 5_488_043_084,
          "is_bot" => true,
          "username" => "exi_dev_bot"
        },
        "left_chat_participant" => %{
          "first_name" => "Exi Dev Bot",
          "id" => 5_488_043_084,
          "is_bot" => true,
          "username" => "exi_dev_bot"
        },
        "message_id" => 67
      },
      "update_id" => 764_803_821
    }
  end

  defp reload(%schema{id: id}) do
    Repo.get(schema, id)
  end
end
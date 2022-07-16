defmodule Exi.TelegramBotTest do
  use Exi.DataCase

  alias Exi.TelegramBot
  alias Exi.Repo
  alias Exi.Logbook.Entry

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

  defp reload(%schema{id: id}) do
    Repo.get(schema, id)
  end
end

defmodule ExiWeb.TelegramBotControllerTest do
  use ExiWeb.ConnCase

  alias Exi.Repo
  alias Exi.Logbook.Entry
  alias Exi.Schemas.Group
  alias Exi.Schemas.GroupUser
  alias Exi.Schemas.User

  describe "logging" do
    test "creates group, user in group, and entry", %{conn: conn} do
      post(conn, Routes.telegram_bot_path(conn, :callback), log_message())
      |> json_response(200)

      group = Repo.one(Group)
      assert group
      assert group.telegram_id == -1_001_712_912_115

      user = Repo.one(User)
      assert user
      assert user.username
      assert user.telegram_id

      group_user = Repo.one(GroupUser)
      assert group_user.user_id == user.id
      assert group_user.group_id == group.id

      entry = Repo.one(Entry)
      assert entry
      assert entry.group_user_id == group_user.id
    end
  end

  defp log_message() do
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
        "message_id" => 2,
        "text" => "10"
      },
      "update_id" => 859_434_146
    }
  end

end

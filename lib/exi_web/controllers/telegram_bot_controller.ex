defmodule ExiWeb.TelegramBotController do
  use ExiWeb, :controller

  @moduledoc """
  ## Adding bot to a group:

    %{
      "my_chat_member" => %{
        "chat" => %{
          "all_members_are_administrators" => true,
          "id" => -762_167_560,
          "title" => "Exi Days",
          "type" => "group"
        },
        "date" => 1_648_282_360,
        "from" => %{
          "first_name" => "Max",
          "id" => 2_144_377,
          "is_bot" => false,
          "language_code" => "en",
          "last_name" => "Grin",
          "username" => "mxgrn"
        },
        "new_chat_member" => %{
          "status" => "member",
          "user" => %{
            "first_name" => "Exi",
            "id" => 5_222_232_628,
            "is_bot" => true,
            "username" => "exico_bot"
          }
        },
        "old_chat_member" => %{
          "status" => "left",
          "user" => %{
            "first_name" => "Exi",
            "id" => 5_222_232_628,
            "is_bot" => true,
            "username" => "exico_bot"
          }
        }
      },
      "update_id" => 859_434_140
    }

  ... then immediately:

  %{
    "message" => %{
      "chat" => %{
        "all_members_are_administrators" => true,
        "id" => -762_167_560,
        "title" => "Exi Days",
        "type" => "group"
      },
      "date" => 1_648_282_360,
      "from" => %{
        "first_name" => "Max",
        "id" => 2_144_377,
        "is_bot" => false,
        "language_code" => "en",
        "last_name" => "Grin",
        "username" => "mxgrn"
      },
      "message_id" => 2,
      "new_chat_member" => %{
        "first_name" => "Exi",
        "id" => 5_222_232_628,
        "is_bot" => true,
        "username" => "exico_bot"
      },
      "new_chat_members" => [
        %{"first_name" => "Exi", "id" => 5_222_232_628, "is_bot" => true, "username" => "exico_bot"}
      ],
      "new_chat_participant" => %{
        "first_name" => "Exi",
        "id" => 5_222_232_628,
        "is_bot" => true,
        "username" => "exico_bot"
      }
    },
    "update_id" => 859_434_141
  }

  ## Removing from chat

  %{
    "message" => %{
      "chat" => %{
        "all_members_are_administrators" => true,
        "id" => -761_170_038,
        "title" => "Max & Exi",
        "type" => "group"
      },
      "date" => 1_648_287_573,
      "from" => %{
        "first_name" => "Max",
        "id" => 2_144_377,
        "is_bot" => false,
        "language_code" => "en",
        "last_name" => "Grin",
        "username" => "mxgrn"
      },
      "left_chat_member" => %{
        "first_name" => "Exi",
        "id" => 5_222_232_628,
        "is_bot" => true,
        "username" => "exico_bot"
      },
      "left_chat_participant" => %{
        "first_name" => "Exi",
        "id" => 5_222_232_628,
        "is_bot" => true,
        "username" => "exico_bot"
      },
      "message_id" => 5
    },
    "update_id" => 859_434_158
  }

  ## Someone posts a message:

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
      "text" => "foo"
    },
    "update_id" => 859_434_146
  }

  ## New group member joins

  %{"message" => %{"chat" => %{"id" => -1001712912115, "title" => "Exi Days", "type" => "supergroup"}, "date" => 1648283082, "from" => %{"first_name" => "Max", "id" => 2144377, "is_bot" => false, "language_code" => "en", "last_name" => "Grin", "username" => "mxgrn"}, "message_id" => 3, "new_chat_member" => %{"first_name" => "!F Bot", "id" => 525677317, "is_bot" => true, "username" => "fragmenterbot"}, "new_chat_members" => [%{"first_name" => "!F Bot", "id" => 525677317, "is_bot" => true, "username" => "fragmenterbot"}], "new_chat_participant" => %{"first_name" => "!F Bot", "id" => 525677317, "is_bot" => true, "username" => "fragmenterbot"}}, "update_id" => 859434147}
  """

  alias Exi.TelegramBot

  def callback(conn, params) do
    TelegramBot.parse_callback!(params)

    json(conn, %{status: "ok"})
  end
end

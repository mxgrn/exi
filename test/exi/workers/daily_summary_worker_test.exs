defmodule Exi.DailySummaryWorkerTest do
  use Exi.DataCase

  import Exi.Factory

  alias Exi.DailySummaryWorker
  alias Exi.Groups
  alias Exi.Users
  alias Exi.Logbook

  test "summary sorts users by their sum amount of logged entries" do
    {:ok, group} = Groups.create(%{telegram_id: 1})
    {:ok, user_1} = Users.create(user_factory())
    {:ok, user_2} = Users.create(user_factory())
    {:ok, user_3} = Users.create(user_factory())
    {:ok, user_4} = Users.create(user_factory())

    {:ok, group_link_1} = Groups.link_to_user(group, user_1)
    {:ok, group_link_2} = Groups.link_to_user(group, user_2)
    Groups.link_to_user(group, user_3)
    Groups.link_to_user(group, user_4)

    Logbook.create_entry(%{group_user_id: group_link_1.id, amount: 1})
    Logbook.create_entry(%{group_user_id: group_link_2.id, amount: 2})

    [line_1, line_2 | _tail] =
      group
      |> DailySummaryWorker.summary_for_group()
      |> String.split("\n")

    assert line_1 =~ user_2.username
    assert line_2 =~ user_1.username

    Logbook.create_entry(%{group_user_id: group_link_1.id, amount: 3})

    [line_1, line_2 | _tail] =
      group
      |> DailySummaryWorker.summary_for_group()
      |> String.split("\n")

    assert line_1 =~ user_1.username
    assert line_2 =~ user_2.username
  end
end

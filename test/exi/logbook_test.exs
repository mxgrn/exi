defmodule Exi.LogbookTest do
  use Exi.DataCase

  alias Exi.Logbook
  alias Exi.Groups
  alias Exi.Users

  import Exi.Factory

  describe "entry_number_in_group/1" do
    test "returns 0 for group with no entries" do
      {:ok, group} = Groups.create(group_factory())

      assert Logbook.entry_number_in_group(group) == 0
    end

    test "returns number of entries" do
      {:ok, group} = Groups.create(group_factory())
      {:ok, user_1} = Users.create(user_factory())
      {:ok, user_2} = Users.create(user_factory())
      {:ok, group_link_1} = Groups.link_to_user(group, user_1)
      {:ok, group_link_2} = Groups.link_to_user(group, user_2)
      Logbook.create_entry(%{group_user_id: group_link_1.id, amount: 1})
      Logbook.create_entry(%{group_user_id: group_link_2.id, amount: 1})
      Logbook.create_entry(%{group_user_id: group_link_2.id, amount: 1})

      assert Logbook.entry_number_in_group(group) == 3
    end
  end
end

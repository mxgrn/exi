defmodule Exi.Groups.GroupTest do
  use Exi.DataCase

  alias Exi.Repo
  alias Exi.Groups

  describe "associations" do
    test "returns empty lists when no assocs were created" do
      {:ok, group} = Groups.create(%{telegram_id: 1})
      group = Repo.preload(group, [:group_users, :entries, :users])
      assert group.entries == []
      assert group.users == []
      assert group.group_users == []
    end
  end
end

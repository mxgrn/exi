defmodule Exi.Groups do
  alias Exi.Schemas.Group
  alias Exi.Schemas.User
  alias Exi.Schemas.GroupUser
  alias Exi.Repo

  def create(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  def link_to_user(%Group{id: group_id}, %User{id: user_id}) do
    %GroupUser{}
    |> GroupUser.changeset(%{group_id: group_id, user_id: user_id})
    |> Repo.insert()
  end
end

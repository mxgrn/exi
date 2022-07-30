defmodule Exi.Groups do
  import Ecto.Query

  alias Exi.Schemas.Group
  alias Exi.Schemas.User
  alias Exi.Schemas.GroupUser
  alias Exi.Repo

  def get(id, preloads \\ []) do
    Repo.get(Group, id)
    |> Repo.preload(preloads)
  end

  def list() do
    from(g in Group, preload: [:users, :entries])
    |> Repo.all()
  end

  def create(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  def update(group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  def change(group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  def link_to_user(%Group{id: group_id}, %User{id: user_id}) do
    %GroupUser{}
    |> GroupUser.changeset(%{group_id: group_id, user_id: user_id})
    |> Repo.insert()
  end
end

defmodule Exi.Groups do
  import Ecto.Query

  alias Exi.Groups.Group
  alias Exi.Users.User
  alias Exi.Groups.GroupUser
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

  def last_daily_report_at(%Group{day_end_time: day_end_time}) do
    result = Map.merge(DateTime.utc_now(), Map.from_struct(day_end_time))

    if DateTime.diff(result, DateTime.utc_now()) >= -5 do
      # time appears in the future or "about now", subtract 24h
      DateTime.add(result, -60 * 60 * 24, :second)
    else
      result
    end
  end

  def next_daily_report_at(%Group{day_end_time: day_end_time}) do
    result = Map.merge(DateTime.utc_now(), Map.from_struct(day_end_time))

    if DateTime.diff(result, DateTime.utc_now()) <= 5 do
      # time appears in the past or "about now", add 24h
      DateTime.add(result, 60 * 60 * 24, :second)
    else
      result
    end
  end
end

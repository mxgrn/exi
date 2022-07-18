defmodule Exi.Telegram do
  @moduledoc """
  Context for Telegram-resources such as groups and users.
  """

  alias Exi.Repo
  alias Exi.Schemas.Group
  alias Exi.Schemas.User
  alias Exi.Schemas.GroupUser
  import Ecto.Query

  def get_group(id) do
    Repo.get(Group, id)
  end

  def list_groups() do
    from(g in Group, preload: [:users, :entries])
    |> Repo.all()
  end

  def ensure_group(attrs) do
    ensure_resource(Group, attrs)
  end

  def ensure_user_in_group(attrs, group) do
    user = ensure_resource(User, attrs)

    group_user = ensure_resource(GroupUser, %{group_id: group.id, user_id: user.id})

    %{user: user, group_user: group_user}
  end

  def ensure_resource(GroupUser, %{user_id: user_id, group_id: group_id} = attrs) do
    do_ensure_resource(GroupUser, %{user_id: user_id, group_id: group_id}, attrs)
  end

  def ensure_resource(schema, %{"id" => id} = attrs) do
    do_ensure_resource(schema, %{telegram_id: id}, Map.merge(attrs, %{"telegram_id" => id}))
  end

  def delete_group(%{"id" => telegram_id}) do
    Repo.get_by(Group, telegram_id: telegram_id)
    |> Repo.delete!()
  end

  def schedule_hourly_reminders(%{id: group_id}) do
    next_hour = %{
      (DateTime.utc_now()
       |> DateTime.add(60 * 60, :second))
      | minute: 0,
        second: 0,
        microsecond: {0, 0}
    }

    %{group_id: group_id}
    |> Exi.EntryReminder.new(scheduled_at: next_hour)
    |> Oban.insert()
  end

  defp do_ensure_resource(schema, get_by, attrs) do
    schema
    |> Repo.get_by(get_by)
    |> case do
      nil ->
        create_resource(schema, attrs)

      record ->
        record
    end
  end

  defp create_resource(Group, attrs) do
    _group = do_create_resource(Group, attrs)
    # schedule_hourly_reminders(group)
  end

  defp create_resource(schema, attrs) do
    do_create_resource(schema, attrs)
  end

  defp do_create_resource(schema, attrs) do
    schema.changeset(struct(schema, %{}), attrs)
    |> Repo.insert!()
  end
end

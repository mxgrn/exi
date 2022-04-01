defmodule Exi.Telegram do
  @moduledoc """
  Context for Telegram-resources such as groups and users.
  """

  alias Exi.Repo
  alias Exi.Telegram.Group
  alias Exi.Telegram.User
  alias Exi.Telegram.GroupUser

  def ensure_group(data) do
    ensure_resource(Group, data)
  end

  def ensure_user_in_group(data, group) do
    user = ensure_resource(User, data)

    group_user = ensure_resource(GroupUser, %{group_id: group.id, user_id: user.id})

    %{user: user, group_user: group_user}
  end

  # DELETE
  def upsert(schema, %{telegram_id: telegram_id} = data) do
    schema
    |> Repo.get_by(%{telegram_id: telegram_id})
    |> case do
      nil ->
        schema |> struct(data) |> Repo.insert!()

      record ->
        record
    end
  end

  def ensure_resource(GroupUser, %{user_id: user_id, group_id: group_id} = data) do
    do_ensure_resource(GroupUser, %{user_id: user_id, group_id: group_id}, data)
  end

  def ensure_resource(schema, %{"id" => id} = data) do
    do_ensure_resource(schema, %{telegram_id: id}, Map.merge(data, %{"telegram_id" => id}))
  end

  defp do_ensure_resource(schema, get_by, data) do
    schema
    |> Repo.get_by(get_by)
    |> case do
      nil ->
        schema.changeset(struct(schema, %{}), data)
        |> Repo.insert!()

      record ->
        record
    end
  end
end

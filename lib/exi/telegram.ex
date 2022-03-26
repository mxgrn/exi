defmodule Exi.Telegram do
  @moduledoc """
  Context related to Telegram info, such as users and groups.
  """

  alias Exi.Repo
  alias Exi.Telegram.Group
  alias Exi.Telegram.User
  alias Exi.Telegram.GroupUser

  def upsert_group(%{"id" => telegram_id}) do
    Repo.insert(%Group{telegram_id: abs(telegram_id)}, on_conflict: :nothing)
  end

  def upsert_user_and_add_to_group(%{"id" => user_telegram_id, "username" => username}, %{
        "id" => group_telegram_id
      }) do
    user = upsert(User, %{telegram_id: user_telegram_id, username: username})
    group = upsert(Group, %{telegram_id: abs(group_telegram_id)})

    Repo.insert(%GroupUser{user_id: user.id, group_id: group.id}, on_conflict: :nothing)
  end

  defp upsert(schema, %{telegram_id: telegram_id} = data) do
    schema
    |> Repo.get_by(%{telegram_id: telegram_id})
    |> case do
      nil ->
        schema |> struct(data) |> Repo.insert!()

      record ->
        record
    end
  end
end

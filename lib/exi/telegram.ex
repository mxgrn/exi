defmodule Exi.Telegram do
  @moduledoc """
  Convert resources from Telegram data
  """

  alias Exi.Repo
  alias Exi.Schemas.Group
  alias Exi.Schemas.User
  alias Exi.Schemas.GroupUser
  alias Exi.Logbook
  alias Exi.Groups

  require Logger

  def log_entry(text, user_data, group_data, message_id) do
    parse_entry(text)
    |> case do
      {:ok, amount} ->
        create_entry(amount, user_data, group_data, message_id)

      _ ->
        nil
    end
  end

  def edit_entry(text, user_data, group_data, message_id) do
    # group = Telegram.ensure_group(group_data)
    Logbook.get_by(%{telegram_message_id: message_id}, group_user: [:group, :user])
    |> case do
      nil ->
        parse_entry(text)
        |> case do
          {:ok, amount} ->
            # create entry, possibly for the first time
            create_entry(amount, user_data, group_data, message_id)

          _ ->
            nil
        end

      entry ->
        parse_entry(text)
        |> case do
          {:ok, amount} ->
            Logbook.update_entry(entry, %{amount: amount})

          _ ->
            Logbook.delete_entry!(entry)
        end
    end
  end

  def parse_entry(text) do
    Logbook.parse_amount(text)
  end

  def create_entry(amount, user_data, group_data, message_id) do
    group = ensure_group(group_data)
    %{group_user: group_user} = ensure_user_in_group(user_data, group)

    Logbook.create_entry(%{
      amount: amount,
      group_user_id: group_user.id,
      telegram_message_id: message_id
    })
  end

  def rename_group(group_data, new_group_name) do
    group = get_group(group_data)

    Groups.update(group, %{telegram_title: new_group_name})
  end

  def ensure_group(params) do
    ensure_resource(Group, params)
  end

  def get_group(%{"id" => telegram_id}) do
    Repo.get_by(Group, telegram_id: telegram_id)
  end

  def get_user(%{"id" => telegram_id}, preloads \\ []) do
    Repo.get_by(User, telegram_id: telegram_id)
    |> Repo.preload(preloads)
  end

  def ensure_user_in_group(attrs, group) do
    user = ensure_resource(User, attrs)

    group_user = ensure_resource(GroupUser, %{group_id: group.id, user_id: user.id})

    %{user: user, group_user: group_user}
  end

  def ensure_resource(GroupUser, %{user_id: user_id, group_id: group_id} = attrs) do
    do_ensure_resource(GroupUser, %{user_id: user_id, group_id: group_id}, attrs)
  end

  def ensure_resource(Group, %{"id" => id, "title" => title} = params) do
    do_ensure_resource(
      Group,
      %{telegram_id: id},
      Map.merge(params, %{"telegram_id" => id, "telegram_title" => title})
    )
  end

  def ensure_resource(schema, %{"id" => id} = params) do
    do_ensure_resource(schema, %{telegram_id: id}, Map.merge(params, %{"telegram_id" => id}))
  end

  def delete_group(%{"id" => telegram_id}) do
    Repo.get_by(Group, telegram_id: telegram_id)
    |> case do
      nil ->
        Logger.warn("Could not delete group with telegram_id #{telegram_id}: group not found")
        :ok

      group ->
        Repo.delete!(group)
    end
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

  defp do_ensure_resource(schema, get_by, params) do
    schema
    |> Repo.get_by(get_by)
    |> case do
      nil ->
        create_resource(schema, params)

      record ->
        record
    end
  end

  defp create_resource(Group, params) do
    do_create_resource(Group, params)
  end

  defp create_resource(schema, params) do
    do_create_resource(schema, params)
  end

  defp do_create_resource(schema, params) do
    schema.changeset(struct(schema, %{}), params)
    |> Repo.insert!()
  end
end

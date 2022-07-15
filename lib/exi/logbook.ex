defmodule Exi.Logbook do
  alias Exi.Repo
  alias Exi.Logbook.Entry

  import Ecto.Query

  def list() do
    Repo.all(Entry)
  end

  def create_entry(attrs) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
  end

  def parse_amount(text) do
    text
    |> Integer.parse()
    |> case do
      {number, _} -> {:ok, number}
      _ -> {:error, :invalid_entry}
    end
  end

  # TODO implement taking period into account
  def entry_number_in_group(%{id: group_id}, _period \\ :day) do
    start_moment = DateTimeUtil.beginning_of_day()

    from(e in Entry,
      join: gu in assoc(e, :group_user),
      where: gu.group_id == ^group_id and e.inserted_at > ^start_moment
    )
    |> Repo.aggregate(:count, :id)
  end
end

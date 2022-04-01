defmodule Exi.Logbook do
  alias Exi.Repo
  alias Exi.Logbook.Entry

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
end

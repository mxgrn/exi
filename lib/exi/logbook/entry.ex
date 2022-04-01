defmodule Exi.Logbook.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :amount, :integer
    field :group_user_id, :id

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:amount, :group_user_id])
    |> validate_required([:amount, :group_user_id])
  end
end

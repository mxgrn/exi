defmodule Exi.Logbook.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exi.Telegram.GroupUser

  schema "entries" do
    belongs_to(:group_user, GroupUser)
    field :amount, :integer

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:amount, :group_user_id])
    |> validate_required([:amount, :group_user_id])
  end
end

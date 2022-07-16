defmodule Exi.Logbook.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exi.Schemas.GroupUser

  schema "entries" do
    belongs_to :group_user, GroupUser
    # rename to value
    field :amount, :integer
    field :telegram_message_id, :integer

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:amount, :group_user_id, :telegram_message_id])
    |> validate_required([:amount, :group_user_id])
  end
end

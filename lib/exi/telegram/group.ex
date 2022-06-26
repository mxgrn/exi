defmodule Exi.Telegram.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exi.Telegram.GroupUser

  schema "groups" do
    has_many :group_users, GroupUser
    has_many :users, through: [:group_users, :user]

    field :telegram_id, :integer

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:telegram_id])
    |> validate_required([:telegram_id])
  end
end

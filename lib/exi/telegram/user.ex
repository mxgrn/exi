defmodule Exi.Telegram.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exi.Telegram.GroupUser

  schema "users" do
    has_many :group_users, GroupUser
    has_many :groups, through: [:group_users, :group]
    field :telegram_id, :integer
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:telegram_id, :username])
    |> validate_required([:telegram_id, :username])
  end
end

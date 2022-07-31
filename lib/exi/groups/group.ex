defmodule Exi.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exi.Groups.GroupUser

  schema "groups" do
    has_many :group_users, GroupUser
    has_many :users, through: [:group_users, :user]
    has_many :entries, through: [:group_users, :entries]

    field :telegram_id, :integer
    field :telegram_title, :string

    field :day_end_time, :time, default: ~T[00:00:00]

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:telegram_id, :telegram_title, :day_end_time])
    |> validate_required([:telegram_id])
  end
end

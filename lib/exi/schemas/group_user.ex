defmodule Exi.Schemas.GroupUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exi.Schemas.User
  alias Exi.Schemas.Group

  schema "group_users" do
    belongs_to :group, Group
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(group_user, attrs) do
    group_user
    |> cast(attrs, [:group_id, :user_id])
    |> validate_required([:group_id, :user_id])
  end
end

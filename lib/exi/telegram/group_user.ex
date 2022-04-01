defmodule Exi.Telegram.GroupUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_users" do
    field :group_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(group_user, attrs) do
    group_user
    |> cast(attrs, [:group_id, :user_id])
    |> validate_required([:group_id, :user_id])
  end
end

defmodule Exi.Telegram.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
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

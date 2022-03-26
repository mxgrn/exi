defmodule Exi.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :telegram_id, :bigint

      timestamps()
    end

    create unique_index(:groups, [:telegram_id])
  end
end

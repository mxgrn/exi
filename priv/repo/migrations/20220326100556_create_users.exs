defmodule Exi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :telegram_id, :bigint
      add :username, :string

      timestamps()
    end

    create unique_index(:users, [:telegram_id, :username])
  end
end

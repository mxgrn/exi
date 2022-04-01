defmodule Exi.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :amount, :integer
      add :group_user_id, references(:group_users, on_delete: :delete_all)

      timestamps()
    end

    create index(:entries, [:group_user_id])
  end
end

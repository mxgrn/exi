defmodule Exi.Repo.Migrations.CreateGroupUsers do
  use Ecto.Migration

  def change do
    create table(:group_users) do
      add :group_id, references(:groups, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:group_users, [:group_id])
    create index(:group_users, [:user_id])
    create unique_index(:group_users, [:group_id, :user_id])
  end
end

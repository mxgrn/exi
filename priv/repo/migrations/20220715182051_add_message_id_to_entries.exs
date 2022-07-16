defmodule Exi.Repo.Migrations.AddMessageIdToEntries do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :telegram_message_id, :integer
    end

    create index(:entries, :telegram_message_id)
  end
end

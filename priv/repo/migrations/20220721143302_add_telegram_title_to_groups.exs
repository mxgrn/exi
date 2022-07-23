defmodule Exi.Repo.Migrations.AddTelegramTitleToGroups do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :telegram_title, :string
    end
  end
end

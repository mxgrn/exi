defmodule Exi.Repo.Migrations.AddDayEndTimeToGroups do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :day_end_time, :time, default: "0:0"
    end
  end
end

defmodule Raffley.Repo.Migrations.AddCharityIdToRaffles do
  use Ecto.Migration

  def change do
    alter table(:raffles) do
      add :charity_id, references(:charities)
    end

    create index(:raffles, [:charity_id])
  end
end

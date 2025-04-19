defmodule Raffley.Repo.Migrations.CreateCharities do
  use Ecto.Migration

  def change do
    create table(:charities) do
      add :name, :string
      add :slug, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:charities, [:slug])
    create unique_index(:charities, [:name])
  end
end

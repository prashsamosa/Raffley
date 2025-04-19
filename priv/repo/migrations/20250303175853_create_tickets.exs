defmodule Raffley.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :price, :integer
      add :comment, :string
      add :raffle_id, references(:raffles, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tickets, [:raffle_id])
    create index(:tickets, [:user_id])
  end
end

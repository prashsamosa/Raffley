defmodule Raffley.Repo.Migrations.AddWinningTicketIdToRaffles do
  use Ecto.Migration

  def change do
    alter table(:raffles) do
      add :winning_ticket_id, references(:tickets, on_delete: :nilify_all)
    end

    create index(:raffles, [:winning_ticket_id])
  end
end

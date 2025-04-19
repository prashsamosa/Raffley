defmodule Raffley.Admin do
  alias Raffley.Raffles
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  import Ecto.Query

  def list_raffles do
    Raffle
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_raffle(attrs \\ %{}) do
    %Raffle{}
    |> Raffle.changeset(attrs)
    |> Repo.insert()
  end

  def change_raffle(%Raffle{} = raffle, attrs \\ %{}) do
    Raffle.changeset(raffle, attrs)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def update_raffle(%Raffle{} = raffle, attrs) do
    raffle
    |> Raffle.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, raffle} ->
        raffle = Repo.preload(raffle, [:charity, :winning_ticket])
        Raffles.broadcast(raffle.id, {:raffle_updated, raffle})
        {:ok, raffle}

      {:error, _} = error ->
        error
    end
  end

  def draw_winner(%Raffle{status: :closed} = raffle) do
    raffle = Repo.preload(raffle, :tickets)

    case raffle.tickets do
      [] ->
        {:error, "No tickets to draw!"}

      tickets ->
        winner = Enum.random(tickets)

        {:ok, _raffle} =
          update_raffle(raffle, %{
            winning_ticket_id: winner.id
          })
    end
  end

  def draw_winner(%Raffle{}) do
    {:error, "Raffle must be closed to draw a winner!"}
  end

  def delete_raffle(%Raffle{} = raffle) do
    Repo.delete(raffle)
  end

  def ticket_tallies do
    query =
      from r in "raffles",
        join: c in "charities",
        on: r.charity_id == c.id,
        left_join: t in "tickets",
        on: t.raffle_id == r.id,
        order_by: [desc: coalesce(sum(t.price), 0)],
        group_by: [r.prize, c.name],
        select: %{
          prize: r.prize,
          charity: c.name,
          ticket_count: count(t.id),
          ticket_total: coalesce(sum(t.price), 0)
        }

    Repo.all(query)
  end
end

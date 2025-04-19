defmodule Raffley.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Raffley.Tickets` context.
  """

  import Raffley.AccountsFixtures
  import Raffley.RafflesFixtures

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    raffle = raffle_fixture()
    user = user_fixture()

    attrs =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        price: 42
      })

    {:ok, ticket} =
      Raffley.Tickets.create_ticket(raffle, user, attrs)

    # Fetch created response so raffle and user associations
    # aren't loaded which the tests don't expect.
    Raffley.Tickets.get_ticket!(ticket.id)
  end
end

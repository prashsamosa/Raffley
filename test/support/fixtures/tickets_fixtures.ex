defmodule Raffley.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Raffley.Tickets` context.
  """

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        price: 42
      })
      |> Raffley.Tickets.create_ticket()

    ticket
  end
end

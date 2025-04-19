defmodule Raffley.RafflesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Admin` context.
  """

  import Raffley.CharitiesFixtures

  @doc """
  Generate a raffle.
  """
  def raffle_fixture(attrs \\ %{}) do
    charity = charity_fixture()

    {:ok, raffle} =
      attrs
      |> Enum.into(%{
        prize: "some prize",
        description: "some description",
        charity_id: charity.id
      })
      |> Raffley.Admin.create_raffle()

    raffle
  end
end

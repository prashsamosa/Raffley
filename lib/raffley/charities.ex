defmodule Raffley.Charities do
  @moduledoc """
  The Charities context.
  """

  import Ecto.Query, warn: false
  alias Raffley.Repo

  alias Raffley.Charities.Charity

  @doc """
  Returns the list of charities.

  ## Examples

      iex> list_charities()
      [%Charity{}, ...]

  """
  def list_charities do
    Repo.all(Charity)
  end

  @doc """
  Gets a single charity.

  Raises `Ecto.NoResultsError` if the Charity does not exist.

  ## Examples

      iex> get_charity!(123)
      %Charity{}

      iex> get_charity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_charity!(id), do: Repo.get!(Charity, id)

  def get_charity_with_raffles!(id) do
    get_charity!(id) |> Repo.preload(:raffles)
  end

  def charity_names_and_ids do
    query =
      from c in Charity,
        order_by: :name,
        select: {c.name, c.id}

    Repo.all(query)
  end

  def charity_names_and_slugs do
    query =
      from c in Charity,
        order_by: :name,
        select: {c.name, c.slug}

    Repo.all(query)
  end

  @doc """
  Creates a charity.

  ## Examples

      iex> create_charity(%{field: value})
      {:ok, %Charity{}}

      iex> create_charity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_charity(attrs \\ %{}) do
    %Charity{}
    |> Charity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a charity.

  ## Examples

      iex> update_charity(charity, %{field: new_value})
      {:ok, %Charity{}}

      iex> update_charity(charity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_charity(%Charity{} = charity, attrs) do
    charity
    |> Charity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a charity.

  ## Examples

      iex> delete_charity(charity)
      {:ok, %Charity{}}

      iex> delete_charity(charity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_charity(%Charity{} = charity) do
    Repo.delete(charity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking charity changes.

  ## Examples

      iex> change_charity(charity)
      %Ecto.Changeset{data: %Charity{}}

  """
  def change_charity(%Charity{} = charity, attrs \\ %{}) do
    Charity.changeset(charity, attrs)
  end
end

defmodule RaffleyWeb.Api.RaffleController do
  use RaffleyWeb, :controller

  alias Raffley.Admin

  def index(conn, _params) do
    raffles = Admin.list_raffles()

    render(conn, :index, raffles: raffles)
  end

  def show(conn, %{"id" => id}) do
    raffle = Admin.get_raffle!(id)

    render(conn, :show, raffle: raffle)
  end

  def create(conn, %{"raffle" => raffle_params}) do
    case Admin.create_raffle(raffle_params) do
      {:ok, raffle} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/raffles/#{raffle}")
        |> render(:show, raffle: raffle)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end
end

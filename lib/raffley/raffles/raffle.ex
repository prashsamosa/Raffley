defmodule Raffley.Raffles.Raffle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "raffles" do
    field :status, Ecto.Enum, values: [:upcoming, :open, :closed], default: :upcoming
    field :description, :string
    field :prize, :string
    field :ticket_price, :integer, default: 1
    field :image_path, :string, default: "/images/placeholder.jpg"

    belongs_to :charity, Raffley.Charities.Charity
    has_many :tickets, Raffley.Tickets.Ticket
    belongs_to :winning_ticket, Raffley.Tickets.Ticket

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(raffle, attrs) do
    raffle
    |> cast(attrs, [
      :prize,
      :description,
      :ticket_price,
      :status,
      :image_path,
      :charity_id,
      :winning_ticket_id
    ])
    |> validate_required([:prize, :description, :ticket_price, :status, :image_path, :charity_id])
    |> validate_length(:description, min: 10)
    |> validate_number(:ticket_price, greater_than_or_equal_to: 1)
    |> assoc_constraint(:charity)
  end
end

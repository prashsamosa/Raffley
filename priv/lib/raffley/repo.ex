defmodule Raffley.Repo do
  use Ecto.Repo,
    otp_app: :raffley,
    adapter: Ecto.Adapters.Postgres
end

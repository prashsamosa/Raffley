defmodule Raffley.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RaffleyWeb.Telemetry,
      Raffley.Repo,
      {DNSCluster, query: Application.get_env(:raffley, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Raffley.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Raffley.Finch},
      # Start a worker by calling: Raffley.Worker.start_link(arg)
      # {Raffley.Worker, arg},
      # Start to serve requests, typically the last entry
      RaffleyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Raffley.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RaffleyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

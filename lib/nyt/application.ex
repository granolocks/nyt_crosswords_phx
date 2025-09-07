defmodule Nyt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NytWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:nyt, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Nyt.PubSub},
      # Start a worker by calling: Nyt.Worker.start_link(arg)
      # {Nyt.Worker, arg},
      # Start to serve requests, typically the last entry
      NytWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nyt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NytWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

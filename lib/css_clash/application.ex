defmodule CssClash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CssClashWeb.Telemetry,
      CssClash.Repo,
      {DNSCluster, query: Application.get_env(:css_clash, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CssClash.PubSub},
      # Start a worker by calling: CssClash.Worker.start_link(arg)
      # {CssClash.Worker, arg},
      # Start to serve requests, typically the last entry
      CssClashWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CssClash.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CssClashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Editor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Editor.Repo,
      # Start the Telemetry supervisor
      EditorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Editor.PubSub},
      # start Presence
      EditorWeb.DocumentPresence,
      # Start the Endpoint (http/https)
      EditorWeb.Endpoint
      # Start a worker by calling: Editor.Worker.start_link(arg)
      # {Editor.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Editor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EditorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

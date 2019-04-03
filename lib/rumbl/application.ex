defmodule Rumbl.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Rumbl.Repo,
      Rumbl.Metrics,
      RumblWeb.Endpoint,
      RumblWeb.Presence,
    ]

    opts = [strategy: :one_for_one, name: Rumbl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    RumblWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule AirDB.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AirDB.Repo
    ]

    opts = [strategy: :one_for_one, name: AirDB.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

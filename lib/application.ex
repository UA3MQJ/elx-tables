defmodule Tables.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Tables.Types.TablesSup, []),
    ]

    opts = [strategy: :one_for_one, name: Tables.Supervisor]
    Supervisor.start_link(children, opts)
  end

end

defmodule Tables.Types.TablesSup do
  # модуль супервизор
  use Supervisor

  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.debug "Tables.Types.TablesSup init"
    children = []

    opts = [strategy: :one_for_one, name: Tables.Supervisor]
    supervise(children, opts)
  end

  def start_table(table_module) do
    spec = %{
      id: table_module,
      start: {table_module, :start_link, []},
      restart: :permanent,
      shutdown: 5000,
      type: :worker}

    {:ok, _pid} = Supervisor.start_child(__MODULE__, spec)
  end

  def stop_table(table_module) do
    _res  = Supervisor.terminate_child(Tables.Types.TablesSup, table_module)
    # Logger.debug "Tables.Types.TablesSup terminate_child res=#{inspect res}"

    _res  = Supervisor.delete_child(Tables.Types.TablesSup, table_module)
    # Logger.debug "Tables.Types.TablesSup delete_child res=#{inspect res}"
  end

end

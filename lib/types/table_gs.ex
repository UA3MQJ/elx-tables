defmodule Tables.Types.TableGS do
  # модуль макро-обертка над ГС хранилищем данных в таблице
  # суть в том, что наследуем - создаем модуль, например Items
  # работаем с ним типа как с таблицей Items.count, Items.id(n) и т.д.

  defmacro __using__(opts) do
    quote location: :keep do

      @name unquote(opts)[:name]

      require Logger

      # GS funcs
      def start_link() do
        GenServer.start_link(__MODULE__, __MODULE__, [name: __MODULE__, spawn_opt: [fullsweep_after: 10]])
      end

      def init(id) do
        ["Elixir"| module] = id
        |> to_string()
        |> String.split(".")

        table_name = module |> Enum.join(".")

        state = %{
          table: initial_data(),
          object_id: __MODULE__,
          table_name: table_name
        }

        {:ok, state}
      end

      # API
      def insert(record),
        do: GenServer.cast(__MODULE__, {:insert, record})

      # def insert(%{:id => id} = record),
      #   do: GenServer.cast(__MODULE__, {:insert, record})
      # def insert(_record), do: throw(:error_data)

      def update(%{:id => id} = record),
        do: GenServer.cast(__MODULE__, {:update, record})
      def update(_record), do: throw(:error_data)

      def delete(id),
        do: GenServer.cast(__MODULE__, {:delete, id})

      def count(),
        do: GenServer.call(__MODULE__, {:count})

      def show(),
        do: GenServer.call(__MODULE__, {:show})

      def id(row_id),
        do: GenServer.call(__MODULE__, {:id, row_id})

      def where(params),
        do: GenServer.call(__MODULE__, {:where, params})

      def drop(),
        do: GlobalTable.drop(__MODULE__)

      # handle casts, calls
      def handle_call({:count}, _from, state),
        do: {:reply, Table.count(state.table), state}

      def handle_call({:id, row_id}, _from, state),
        do: {:reply, Table.id(state.table, row_id), state}

      def handle_call({:where, params}, _from, state),
        do: {:reply, Table.where(state.table, params), state}

      def handle_call({:show}, _from, state) do
        {:reply, Table.show(state.table), state}
      end

      def handle_cast({:insert, record}, state),
        do: {:noreply, put_in(state, [:table], Table.insert(state.table, record))}

      def handle_cast({:update, record}, state),
        do: {:noreply, put_in(state, [:table], Table.update(state.table, record))}

      def handle_cast({:delete, id}, state),
        do: {:noreply, put_in(state, [:table], Table.delete(state.table, id))}


      def terminate(reason, _state) do
        Logger.info ">>>>>>> SYS TABLE terminating: #{inspect self()}: #{inspect reason}"
        :ok
      end

      # заполнение данных по умолчанию
      def initial_data() do
        Table.create(@name)
      end

      defoverridable [initial_data: 0]
    end
  end
end

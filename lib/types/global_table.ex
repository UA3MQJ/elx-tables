defmodule GlobalTable do
  # Create Module-table
  # модуль для динамического создания модулей-таблиц

  def create(table_name) do
    ["Elixir", module] = table_name
    |> to_string()
    |> String.split(".")

    module_text = '''
      defmodule #{module} do
        alias Tables.Types.TableGS
        alias Table
        use TableGS, name: __MODULE__
        require Logger

        def initial_data() do
          Table.create(__MODULE__)
        end

      end
    '''

    Code.compile_string(module_text)

    Tables.Types.TablesSup.start_table(table_name)
  end

  def drop(table_name) do
    Tables.Types.TablesSup.stop_table(table_name)
  end
end

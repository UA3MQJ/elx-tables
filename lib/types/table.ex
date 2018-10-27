defmodule Table do
  # Модуль для работы с таблицами, которые хранятся в мапах

  require Logger

  defstruct name: nil,        # имя таблицы
            count: 0,         # количество записей
            mod: __MODULE__,  # модуль объекта
            records: %{},     # записи
            autoinc: 1,       # autoincrement значение
            result: nil       # результат последней операции над таблицей

  # создать таблицу
  def create(name) do
    %__MODULE__{name: name}
  end

  # добавляет запись. либо перезаписывает полностью, если такой id уже есть
  def insert(table, %{:id => id} = record) do
    new_record = %{id => record}
    new_records = Map.merge(table.records, new_record)
    new_count = if table.records[id]==nil, do: table.count + 1, else: table.count
    Map.merge(table, %{count:   new_count,
                       records: new_records,
                       result:  record})
  end

  # добавляет запись. id нет. поэтому он автоинкрементится
  def insert(table, record) do
    rec_with_id = Map.merge(record, %{id: table.autoinc})
    new_table = insert(table, rec_with_id)
    update_in(new_table.autoinc, &(&1 + 1))
  end

  # update позволяет менять только отдельные поля, не меняя старые
  def update(table, %{:id => id} = record) do
    old_record = case table.records[id] do
      nil -> %{id: id}
      record -> record
    end

    new_record = %{id => Map.merge(old_record, record)}
    new_records = Map.merge(table.records, new_record)
    new_count = if table.records[id]==nil, do: table.count + 1, else: table.count
    Map.merge(table, %{count:   new_count,
                       records: new_records,
                       result:  record})
  end

  def update(_table, _record), do: throw(:error_data)

  # delete удаляет запись по ид
  def delete(table, id) do
    case table.records[id] do
      nil ->
        table
      _record ->
        new_records = Map.delete(table.records, id)
        new_count = table.count - 1
        Map.merge(table, %{count:   new_count,
                           records: new_records,
                           result:  id})
    end
  end


  # def count(table), do: table.records |> Map.keys() |> length()
  def count(table), do: table.count

  # по id
  def id(table, value) do
    case table.records[value] do
      nil -> %{}
      record -> record
    end
  end

  # может быть, как по id: так и по другим ключам
  # поиск всех записей, у которых по ключу совпадает значение
  def where(table, params) when is_list(params) do
    # params
    table.records
    |> Enum.filter(fn({_k, m_data}) -> # v - это мапа data со всеми полями и значениями
                     # v[key]==value
                     # результат значения полей списка с маповыми [t,t,t,f]
                     res_list = params
                     |> Enum.map(fn({k, v}) -> m_data[k] == v end)

                     !(false in res_list) # если ни одного false нет. значит совпало
                   end)
    |> Enum.into(%{})
  end

  def show(table) do
    columns = table.records
    |> Enum.reduce([], fn({_k, v}, acc) ->
                           tv = Enum.reduce(v, %{}, fn({k, v}, acc2) ->
                             capt_len = String.length(inspect(k)) + 2
                             val_len = String.length(inspect(v)) + 2
                             case capt_len > val_len do
                               true ->  Map.merge(acc2, %{k => capt_len})
                               _else -> Map.merge(acc2, %{k => val_len})
                             end
                           end)
                          [tv] ++ acc
                        end)
    |> Enum.reduce(%{}, fn(v, acc) ->
                            res = Enum.map(v, fn({k, v}) ->
                                                cond do
                                                  acc[k] == nil -> {k, v}
                                                  acc[k] > v -> {k, acc[k]}
                                                  true -> {k, v}
                                                end
                                              end)
                            |> Enum.into(%{})
                          Map.merge(acc, res)
                        end)

    tbl1 = columns
    |> Enum.reduce("+", fn({_k, v}, acc) ->
                         acc <> String.duplicate("-", v) <> "+"
                       end)

    tbl2 = columns
    |> Enum.reduce("|", fn({k, v}, acc) ->
                         acc <> " " <> String.pad_trailing(inspect(k), v - 1, " ") <> "|"
                       end)

    tbl3 = table.records
    |> Enum.reduce("", fn({_k, v}, acc) ->
                         str = Enum.reduce(columns, "|", fn({sk, sv}, acc2) ->
                                                    acc2 <> " " <> String.pad_trailing(inspect(v[sk]), sv - 1, " ") <> "|"
                                                  end) 

                         acc <> str <> "\n"
                       end)

    # Logger.debug 
    "\n * Table: #{inspect table.name}\n"
    <> tbl1 <> "\n"
    <> tbl2 <> "\n"
    <> tbl1 <> "\n"
    <> tbl3 <> tbl1 <> "\n"
  end
end

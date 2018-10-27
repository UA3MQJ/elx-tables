defmodule TableTest do
  use ExUnit.Case

  require Logger
  # тестирование модуля таблиц
  # test of table
  # mix test --only table_test
  
  @tag table_test: true
  @tag external: true

  test "table create" do
    # автоинкремент (autoincrement test)
    t0 = Table.create("ainc")
    |> Table.insert(%{name: "a"})
    |> Table.insert(%{name: "b"})
    |> Table.insert(%{name: "c"})

    assert t0.result.id == 3

    # создаем таблицу - должна быть таблица %Table{}
    t1 = Table.create("Items")
    assert %Table{} = t1

    # вставить несколько записей в таблицу
    t2 = t1
    |> Table.insert(%{id: 1, group_id: 0, user_id: 1000})
    |> Table.insert(%{id: 2, group_id: 1, user_id: 1000})
    |> Table.insert(%{id: 3, group_id: 2, user_id: 1000})
    |> Table.insert(%{id: 4, group_id: 1, user_id: 2000})
    |> Table.insert(%{id: 5, group_id: 2, user_id: 2000})
    |> Table.insert(%{id: 6, group_id: 3, user_id: 2000})
    |> Table.insert(%{id: 7, group_id: 2, user_id: 3000})
    |> Table.insert(%{id: 8, group_id: 3, user_id: 4000})
    |> Table.insert(%{id: 9, group_id: 4, user_id: 5000})

    # count test на количество записей в таблице
    assert Table.count(t2) == 9

    # после добавления станет 10
    # after insert count must be == 10
    assert 10 == t2
                 |> Table.insert(%{id: 10, group_id: 4, user_id: 5000})
                 |> Table.count()

    # но если ИД совпадает, то оно обновит
    # if id exist then record update
    assert  9 == t2
                 |> Table.insert(%{id: 1, group_id: 4, user_id: 5000})
                 |> Table.count()


    # выбираем данные из таблицы по ид
    # и сверяем значение полей %{id: 1, group_id: 0, user_id: 1000}
    # select by id and check fields
    assert (t2 |> Table.id(1)).id       == 1
    assert (t2 |> Table.id(1)).group_id == 0
    assert (t2 |> Table.id(1)).user_id  == 1000

    # where test:
    # Table.keys(table, key_name, key_value)
    # поиск по любому полю на равенство ключа значению
    # where user_id = 2000
    # результат - мапа id -> данные, которые подходят под условие
    assert [4, 5, 6] = t2 |> Table.where(user_id: 2000) |> Map.keys()
    assert [5] = t2 |> Table.where(user_id: 2000, group_id: 2) |> Map.keys()

    # update test (update only selected fields)
    # update позволяет менять только отдельные поля, не меняя старые
    assert %{id: 1, group_id: 0, user_id: 1000} = Table.id(t2, 1)
    t3 = Table.update(t2, %{id: 1, group_id: 500})
    assert %{id: 1, group_id: 500, user_id: 1000} = Table.id(t3, 1)

    # если update данные без ID то будет ошибка
    # update must have ID
    assert catch_throw(Table.update(t1, %{group_id: 0, user_id: 1000})) == :error_data

    # detele test
    t4 = Table.delete(t3, 1)
    assert Table.count(t3) - 1 == Table.count(t4)

    t5 = Table.delete(t4, 1)
    assert Table.count(t5) == Table.count(t4)

  end

end

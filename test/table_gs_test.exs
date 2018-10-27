defmodule TableGSTest do
  use ExUnit.Case

  require Logger
  # тестирование модуля TableGS макро обертки
  # mix test --only tablegs_test
  
  @tag tablegs_test: true
  @tag external: true

  test "table_gs" do

    {:ok, _pid} = GlobalTable.create(TItems)

    %{id: 1, name: "Лопата",               amount: 100, price: 120} |> TItems.insert()
    %{id: 2, name: "Лопата совковая",      amount: 200, price: 170} |> TItems.insert()
    %{id: 3, name: "Лопата нержавеющая",   amount: 200, price: 220} |> TItems.insert()
    %{id: 4, name: "Лопата для снега",     amount: 250, price: 270} |> TItems.insert()
    %{id: 5, name: "Лопата автомобильная", amount: 300, price: 320} |> TItems.insert()

    {:ok, _pid} = GlobalTable.create(TCompanies)
    %{id: 1, name: "ООО Дачный сезон"}         |> TCompanies.insert()
    %{id: 2, name: "Рога и копыта"}            |> TCompanies.insert()
    %{id: 3, name: "ООО Вместе весело копать"} |> TCompanies.insert()

    assert TCompanies.count() == 3

    # update через insert - полная замена
    # update via insert == full record replace
    %{id: 1, name: "ООО Дачный сезон UPD"}     |> TCompanies.insert()

    assert TCompanies.count() == 3


    assert TItems.id(3).amount == 200

    assert TItems.where(amount: 200)[2].amount == 200
    assert TItems.where(amount: 200)[3].amount == 200

    # update позволяет менять только отдельные поля, не меняя старые
    assert %{id: 5, name: "Лопата автомобильная", amount: 300, price: 320} = TItems.id(5)
    TItems.update(%{id: 5, amount: 350})
    assert %{id: 5, name: "Лопата автомобильная", amount: 350, price: 320} = TItems.id(5)

    assert catch_throw(TItems.update(%{amount: 350})) == :error_data

    # delete test
    c1 = TItems.count()
    TItems.delete(1)
    c2 = TItems.count()
    assert c1 - 1 == c2
    TItems.delete(1)
    c3 = TItems.count()
    assert c3 == c2

    # прибиваем таблицу
    GlobalTable.drop(TCompanies)

    {:ok, _pid} = GlobalTable.create(TCompanies)
    TCompanies.drop()
  end

end

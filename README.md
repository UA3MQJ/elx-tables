# Tables

Tables in Elixir. Experimental Library. Use elixir macro-programming, dynamic module creation, and standart sup tree control of GS.

## Installation

For local tables it is enough to add a dependency.
```elixir
def deps do
  [
    {:tables, git: "git@github.com:UA3MQJ/elx-tables.git"}
  ]
end
```

For global tables, you need to add an application to the list of running apps, since Each table is placed under the control of the application's supervisor tree.

```elixir
applications: [..., :tables]
```

## Usage

### Local tables

Create table
```elixir
iex(1)> t1 = Table.create("Items")

%Table{
  autoinc: 1,
  count: 0,
  mod: Table,
  name: "Items",
  records: %{},
  result: nil
}
```

Insert data.
If the id field is not specified, it will be generated automatically.

```elixir
iex(2)> t2 = t1 \
|> Table.insert(%{id: 1, group_id: 0, user_id: 1000}) \
|> Table.insert(%{id: 2, group_id: 1, user_id: 1000}) \
|> Table.insert(%{id: 3, group_id: 2, user_id: 1000}) \
|> Table.insert(%{id: 4, group_id: 1, user_id: 2000}) \
|> Table.insert(%{id: 5, group_id: 2, user_id: 2000}) \
|> Table.insert(%{id: 6, group_id: 3, user_id: 2000}) \
|> Table.insert(%{id: 7, group_id: 2, user_id: 3000}) \
|> Table.insert(%{id: 8, group_id: 3, user_id: 4000}) \
|> Table.insert(%{id: 9, group_id: 4, user_id: 5000})

%Table{
  autoinc: 1,
  count: 9,
  mod: Table,
  name: "Items",
  records: %{
    1 => %{group_id: 0, id: 1, user_id: 1000},
    2 => %{group_id: 1, id: 2, user_id: 1000},
    3 => %{group_id: 2, id: 3, user_id: 1000},
    4 => %{group_id: 1, id: 4, user_id: 2000},
    5 => %{group_id: 2, id: 5, user_id: 2000},
    6 => %{group_id: 3, id: 6, user_id: 2000},
    7 => %{group_id: 2, id: 7, user_id: 3000},
    8 => %{group_id: 3, id: 8, user_id: 4000},
    9 => %{group_id: 4, id: 9, user_id: 5000}
  },
  result: %{group_id: 4, id: 9, user_id: 5000}
}
```

Operations

```elixir
# record count
iex(3)> Table.count(t2)
9

# select by id
iex(4)> Table.id(t2, 1)
%{group_id: 0, id: 1, user_id: 1000}

# or
iex(5)> t2 |> Table.id(1)
%{group_id: 0, id: 1, user_id: 1000}

# get fields
iex(6)> (t2 |> Table.id(1)).user_id
1000

# filter "WHERE" on table
iex(7)> t2 |> Table.where(user_id: 2000)
%{
  4 => %{group_id: 1, id: 4, user_id: 2000},
  5 => %{group_id: 2, id: 5, user_id: 2000},
  6 => %{group_id: 3, id: 6, user_id: 2000}
}

# update field of record
iex(8)> t2 |> Table.id(1)
%{group_id: 0, id: 1, user_id: 1000}
iex(9)> t2 |> Table.update(%{id: 1, user_id: 2000}) |> Table.id(1)
%{group_id: 0, id: 1, user_id: 2000}

# delete by id
iex(10)> t2 |> Table.delete(1) |> Table.id(1)
%{}

# show table
iex(11)> t2 |> Table.show() |> IO.puts

 * Table: "Items"
+-----------+-----+----------+
| :group_id | :id | :user_id |
+-----------+-----+----------+
| 0         | 1   | 1000     |
| 1         | 2   | 1000     |
| 2         | 3   | 1000     |
| 1         | 4   | 2000     |
| 2         | 5   | 2000     |
| 3         | 6   | 2000     |
| 2         | 7   | 3000     |
| 3         | 8   | 4000     |
| 4         | 9   | 5000     |
+-----------+-----+----------+

```

### Global tables

Access to global tables is possible from any process. Made using hack with dynamic creation of a module named by name of table. Each table is a gen_server. Gen_server controlled by supervisor tree of application :tables. Table data is stored in the state of the gen_server.

Create table
```elixir
{:ok, _pid} = GlobalTable.create(TItems)
```
Data handling methods are the same as for local tables.

Insert Data
```elixir
%{id: 1, name: "Лопата",               amount: 100, price: 120} |> TItems.insert()
%{id: 2, name: "Лопата совковая",      amount: 200, price: 170} |> TItems.insert()
%{id: 3, name: "Лопата нержавеющая",   amount: 200, price: 220} |> TItems.insert()
%{id: 4, name: "Лопата для снега",     amount: 250, price: 270} |> TItems.insert()
%{id: 5, name: "Лопата автомобильная", amount: 300, price: 320} |> TItems.insert()
```

Select Data
```elixir
# by id
assert TItems.id(3).amount == 200

# filter by amount when get by id and test amount field
assert TItems.where(amount: 200)[2].amount == 200
assert TItems.where(amount: 200)[3].amount == 200

# show
iex(7)> TItems.show() |> IO.puts

 * Table: TItems
+---------+-----+------------------------+--------+
| :amount | :id | :name                  | :price |
+---------+-----+------------------------+--------+
| 100     | 1   | "Лопата"               | 120    |
| 200     | 2   | "Лопата совковая"      | 170    |
| 200     | 3   | "Лопата нержавеющая"   | 220    |
| 250     | 4   | "Лопата для снега"     | 270    |
| 300     | 5   | "Лопата автомобильная" | 320    |
+---------+-----+------------------------+--------+

```

Delete Data
```elixir
c1 = TItems.count()
TItems.delete(1)
c2 = TItems.count()
assert c1 - 1 == c2
```

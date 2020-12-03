defmodule Advent2020.Problem3 do
  def run(:part1) do
    rows = load()
    row_length = Enum.count(Enum.at(rows, 0))
    traverse(rows: rows, row_length: row_length, index: 0, right_amount: 3, down_amount: 1)
  end

  def run(:part2) do
    rows = load()
    row_length = Enum.count(Enum.at(rows, 0))

    [
      [right_amount: 1, down_amount: 1],
      [right_amount: 3, down_amount: 1],
      [right_amount: 5, down_amount: 1],
      [right_amount: 7, down_amount: 1],
      [right_amount: 1, down_amount: 2]
    ]
    |> Enum.map(fn right_amount: right_amount, down_amount: down_amount ->
      traverse(
        rows: rows,
        row_length: row_length,
        index: 0,
        right_amount: right_amount,
        down_amount: down_amount
      )
    end)
    |> Enum.reduce(1, fn trees, result -> result * trees end)
  end

  def load() do
    File.read('input3.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.map(fn row -> String.graphemes(row) |> Enum.map(&(&1 == "#")) end)
  end

  def traverse([{:rows, []} | _rest]), do: 0

  def traverse(
        rows: rows,
        row_length: row_length,
        index: index,
        right_amount: right_amount,
        down_amount: down_amount
      ) do
    row = hd(rows)
    sum = (Enum.at(row, index) && 1) || 0

    sum +
      traverse(
        rows: Enum.drop(rows, down_amount),
        row_length: row_length,
        index: rem(index + right_amount, row_length),
        right_amount: right_amount,
        down_amount: down_amount
      )
  end
end

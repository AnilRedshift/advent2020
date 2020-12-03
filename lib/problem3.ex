defmodule Advent2020.Problem3 do
  def run(:part1) do
    rows = load()
    row_length = Enum.count(Enum.at(rows, 0))
    traverse(rows, row_length, 0)
  end

  def load() do
    File.read('input3.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.map(fn row -> String.graphemes(row) |> Enum.map(&(&1 == "#")) end)
  end

  def traverse([], _row_length, _index), do: 0

  def traverse([row | rest], row_length, index) do
    sum = (Enum.at(row, index) && 1) || 0
    sum + traverse(rest, row_length, rem(index + 3, row_length))
  end
end

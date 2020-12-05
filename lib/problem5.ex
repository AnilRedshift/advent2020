defmodule Advent2020.Problem5 do
  def run(:part1) do
    load()
    |> Enum.map(&seat_id/1)
    |> Enum.max()
  end

  def run(:part2) do
    sorted_ids =
      load()
      |> Enum.map(&seat_id/1)
      |> Enum.sort()

    first = hd(sorted_ids)

    # This also could be found with binary search but ... #lazy
    Enum.with_index(sorted_ids)
    |> Enum.find(fn {val, index} -> val - first != index end)
    |> elem(0)
    # subtract 1 for the first missing one
    |> (&(&1 - 1)).()
  end

  def load() do
    File.read('input5.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  defp parse(line) do
    {rows, columns} =
      String.graphemes(line)
      |> Enum.map(fn char ->
        case char do
          "F" -> :lower
          "B" -> :upper
          "L" -> :lower
          "R" -> :upper
        end
      end)
      |> Enum.split(7)

    [rows: rows, columns: columns]
  end

  defp binary_id(_rest, min, max) when min == max, do: min
  defp binary_id([:lower | rest], min, max), do: binary_id(rest, min, mid(min, max))
  defp binary_id([:upper | rest], min, max), do: binary_id(rest, mid(min, max) + 1, max)

  defp seat_id(rows: rows, columns: columns) do
    binary_id(rows, 0, 127) * 8 + binary_id(columns, 0, 7)
  end

  defp mid(min, max), do: floor(min + (max - min) / 2)
end

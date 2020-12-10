defmodule Advent2020.Problem10 do
  def run(:part1) do
    counts =
      load()
      |> Enum.sort()
      |> Enum.reduce({0, %{1 => 0, 2 => 0, 3 => 0}}, fn elem, {prev, counts} ->
        gap = elem - prev
        counts = Map.update(counts, gap, 0, &(&1 + 1))
        {elem, counts}
      end)
      |> elem(1)
      |> Map.update(3, 0, &(&1 + 1))

    Map.fetch!(counts, 1) * Map.fetch!(counts, 3)
  end

  def load() do
    File.read('input10.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&to_int/1)
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

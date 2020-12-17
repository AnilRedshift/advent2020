defmodule Advent2020.Problem17 do
  def run(:part1) do
    load()
    |> cycle(0)
    |> Enum.count()
  end

  def load() do
    File.read('input17.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      Enum.with_index(row)
      |> Enum.map(fn {val, x} -> {{x, y}, val} end)
    end)
    |> Enum.reject(fn {_pos, val} -> val == :inactive end)
    |> Enum.map(fn {{x, y}, _val} -> {x, y, 0} end)
    |> MapSet.new()
  end

  def parse(line) do
    String.graphemes(line)
    |> Enum.map(fn
      "#" -> :active
      "." -> :inactive
    end)
  end

  defp cycle(grid, 6), do: grid

  defp cycle(grid, count) do
    Enum.flat_map(grid, &neighbors/1)
    |> MapSet.new()
    |> MapSet.union(grid)
    |> Enum.map(fn pos ->
      active_neighbors =
        neighbors(pos)
        |> Enum.count(&MapSet.member?(grid, &1))

      {pos, active_neighbors}
    end)
    |> Enum.reduce(MapSet.new(), fn {pos, active_neighbors}, new_grid ->
      is_active = MapSet.member?(grid, pos)

      if (is_active and active_neighbors in [2, 3]) or (!is_active and active_neighbors == 3) do
        MapSet.put(new_grid, pos)
      else
        MapSet.delete(new_grid, pos)
      end
    end)
    |> cycle(count + 1)
  end

  defp neighbors({x, y, z}) do
    Enum.map((x - 1)..(x + 1), fn new_x ->
      Enum.map((y - 1)..(y + 1), fn new_y ->
        Enum.map((z - 1)..(z + 1), fn new_z -> {new_x, new_y, new_z} end)
      end)
    end)
    |> List.flatten()
    |> Enum.reject(&(&1 == {x, y, z}))
  end
end

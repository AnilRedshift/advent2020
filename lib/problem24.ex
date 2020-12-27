defmodule Advent2020.Problem24 do
  def run(:part1) do
    load()
    |> Enum.reduce(%{}, &flip/2)
    |> Enum.count()
  end

  def run(:part2) do
    grid =
      load()
      |> Enum.reduce(%{}, &flip/2)

    game_of_life(%{grid: grid, day: 0, max_days: 100})
    |> Enum.count()
  end

  def load() do
    File.read('input24.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  defp parse(""), do: []

  defp parse("se" <> line) do
    [:southeast | parse(line)]
  end

  defp parse("sw" <> line) do
    [:southwest | parse(line)]
  end

  defp parse("ne" <> line) do
    [:northeast | parse(line)]
  end

  defp parse("nw" <> line) do
    [:northwest | parse(line)]
  end

  defp parse("e" <> line) do
    [:east | parse(line)]
  end

  defp parse("w" <> line) do
    [:west | parse(line)]
  end

  defp flip(instructions, grid) do
    # a _ b _ c _
    # _ d _ e _ f
    # g _ h _ i _
    flip(instructions, grid, {0, 0})
  end

  defp flip([], grid, pos) when :erlang.is_map_key(pos, grid) do
    Map.delete(grid, pos)
  end

  defp flip([], grid, pos) do
    Map.put(grid, pos, :black)
  end

  defp flip([:west | directions], grid, {x, y}) do
    flip(directions, grid, {x - 2, y})
  end

  defp flip([:east | directions], grid, {x, y}) do
    flip(directions, grid, {x + 2, y})
  end

  defp flip([:southwest | directions], grid, {x, y}) do
    flip(directions, grid, {x - 1, y - 1})
  end

  defp flip([:southeast | directions], grid, {x, y}) do
    flip(directions, grid, {x + 1, y - 1})
  end

  defp flip([:northwest | directions], grid, {x, y}) do
    flip(directions, grid, {x - 1, y + 1})
  end

  defp flip([:northeast | directions], grid, {x, y}) do
    flip(directions, grid, {x + 1, y + 1})
  end

  defp game_of_life(%{grid: grid, day: day, max_days: max_days}) when day == max_days do
    grid
  end

  defp game_of_life(%{grid: grid, day: day} = args) do
    grid =
      Map.keys(grid)
      |> Enum.flat_map(&neighbors/1)
      |> MapSet.new()
      |> MapSet.union(MapSet.new(Map.keys(grid)))
      |> Enum.map(fn pos -> {pos, Map.get(grid, pos, :white)} end)
      |> Enum.map(fn {pos, value} ->
        neighbor_count = Enum.count(neighbors(pos), &Map.has_key?(grid, &1))
        {pos, value, neighbor_count}
      end)
      |> Enum.reduce(grid, fn
        {pos, :black, neighbor_count}, new_grid ->
          if neighbor_count in [0, 3, 4, 5, 6] do
            Map.delete(new_grid, pos)
          else
            new_grid
          end

        {pos, :white, neighbor_count}, new_grid ->
          if neighbor_count == 2 do
            Map.put(new_grid, pos, :black)
          else
            new_grid
          end
      end)

    game_of_life(%{args | grid: grid, day: day + 1})
  end

  defp neighbors({x, y}) do
    [
      {x + 2, y},
      {x - 2, y},
      {x + 1, y + 1},
      {x + 1, y - 1},
      {x - 1, y + 1},
      {x - 1, y - 1}
    ]
  end
end

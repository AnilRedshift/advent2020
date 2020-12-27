defmodule Advent2020.Problem24 do
  def run(:part1) do
    load()
    |> Enum.reduce(%{}, &flip/2)
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
end

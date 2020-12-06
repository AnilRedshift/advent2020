defmodule Advent2020.Problem6 do
  def run(:part1) do
    load()
    |> Enum.map(&unique/1)
    |> Enum.sum()
  end

  def load() do
    File.read('input6.txt')
    |> elem(1)
    |> String.split("\n\n")
  end

  def unique(lines) do
    String.graphemes(lines)
    |> Enum.reject(&(&1 == "\n"))
    |> Enum.into(MapSet.new())
    |> Enum.count()
  end
end

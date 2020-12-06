defmodule Advent2020.Problem6 do
  def run(:part1) do
    load()
    |> Enum.map(&unique/1)
    |> Enum.sum()
  end

  def run(:part2) do
    load()
    |> Enum.map(&every/1)
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

  def every(lines) do
    String.split(lines, "\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.reject(&(&1 == "\n" || &1 == []))
    |> Enum.map(&Enum.into(&1, MapSet.new()))
    |> Enum.reduce(&MapSet.intersection(&1, &2))
    |> Enum.count()
  end
end

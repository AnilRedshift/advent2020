defmodule Advent2020.Problem2 do
  defmodule Row do
    defstruct min: 0, max: 0, char: nil, password: nil
  end

  def run(part) do
    load()
    |> Enum.count(&is_valid?(part, &1))
  end

  def load() do
    File.read('input2.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.map(&parse/1)
  end

  def parse(line) do
    Regex.run(~r/^(\d+)-(\d+)\s+(.):\s+(\S+)$/, line)
    |> case do
      nil ->
        nil

      [_whole, min, max, char, password] ->
        %Row{min: to_int(min), max: to_int(max), char: char, password: password}
    end
  end

  def is_valid?(_part, nil), do: false

  def is_valid?(:part1, row = %Row{}) do
    counts =
      String.graphemes(row.password)
      |> Enum.count(&(&1 == row.char))

    counts >= row.min && counts <= row.max
  end

  def is_valid?(:part2, row = %Row{}) do
    graphemes = String.graphemes(row.password)
    min_valid = Enum.at(graphemes, row.min - 1) == row.char
    max_valid = Enum.at(graphemes, row.max - 1) == row.char
    (min_valid && !max_valid) || (!min_valid && max_valid)
  end

  def to_int(val), do: Integer.parse(val) |> elem(0)
end

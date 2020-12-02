defmodule Advent2020.Problem2 do
  defmodule Row do
    defstruct min: 0, max: 0, char: nil, password: nil
  end

  def run(:part1) do
    load()
    |> Enum.count(&is_valid?/1)
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

  @spec is_valid?(nil | Advent2020.Problem2.Row.t()) :: boolean
  def is_valid?(nil), do: false

  def is_valid?(row = %Row{}) do
    counts =
      String.graphemes(row.password)
      |> Enum.count(&(&1 == row.char))

    counts >= row.min && counts <= row.max
  end

  def to_int(val), do: Integer.parse(val) |> elem(0)
end

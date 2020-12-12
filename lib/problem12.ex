defmodule Advent2020.Problem12 do
  def run(:part1) do
    commands = load()

    move(commands: commands, pos: {0, 0}, bearing: :east)
    |> manhattan()
  end

  def load() do
    File.read('input12.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  defp parse(<<action::binary-size(1)>> <> amount) do
    command =
      case action do
        "N" -> :north
        "S" -> :south
        "E" -> :east
        "W" -> :west
        "L" -> :left
        "R" -> :right
        "F" -> :forward
      end

    {command, to_int(amount)}
  end

  defp move(commands: [], pos: pos, bearing: _bearing), do: pos

  defp move(commands: [{:north, amount} | rest], pos: {ns, ew}, bearing: bearing) do
    move(commands: rest, pos: {ns + amount, ew}, bearing: bearing)
  end

  defp move(commands: [{:south, amount} | rest], pos: {ns, ew}, bearing: bearing) do
    move(commands: rest, pos: {ns - amount, ew}, bearing: bearing)
  end

  defp move(commands: [{:east, amount} | rest], pos: {ns, ew}, bearing: bearing) do
    move(commands: rest, pos: {ns, ew + amount}, bearing: bearing)
  end

  defp move(commands: [{:west, amount} | rest], pos: {ns, ew}, bearing: bearing) do
    move(commands: rest, pos: {ns, ew - amount}, bearing: bearing)
  end

  defp move(commands: [{direction, amount} | rest], pos: pos, bearing: bearing)
       when direction in [:left, :right] do
    order =
      (direction == :left && [:north, :west, :south, :east]) || [:north, :east, :south, :west]

    new_bearing =
      Stream.cycle(order)
      |> Stream.drop_while(&(&1 != bearing))
      |> Stream.drop(floor(amount / 90))
      |> Enum.take(1)
      |> hd()

    move(commands: rest, pos: pos, bearing: new_bearing)
  end

  defp move(commands: [{:forward, amount} | rest], pos: pos, bearing: bearing) do
    move(commands: [{bearing, amount} | rest], pos: pos, bearing: bearing)
  end

  defp manhattan({ns, ew}), do: abs(ns) + abs(ew)

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

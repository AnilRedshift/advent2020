defmodule Advent2020.Problem12 do
  def run(:part1) do
    commands = load()

    move(commands: commands, pos: {0, 0}, bearing: :east)
    |> manhattan()
  end

  def run(:part2) do
    commands = load()

    move(commands: commands, waypoint: {1, 10}, pos: {0, 0})
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

  # part 1
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

  # part2
  defp move(commands: [], waypoint: _waypoint, pos: pos), do: pos

  defp move(
         commands: [{:north, amount} | rest],
         waypoint: {ns, ew},
         pos: pos
       ) do
    move(commands: rest, waypoint: {ns + amount, ew}, pos: pos)
  end

  defp move(
         commands: [{:south, amount} | rest],
         waypoint: {ns, ew},
         pos: pos
       ) do
    move(commands: rest, waypoint: {ns - amount, ew}, pos: pos)
  end

  defp move(
         commands: [{:east, amount} | rest],
         waypoint: {ns, ew},
         pos: pos
       ) do
    move(commands: rest, waypoint: {ns, ew + amount}, pos: pos)
  end

  defp move(
         commands: [{:west, amount} | rest],
         waypoint: {ns, ew},
         pos: pos
       ) do
    move(commands: rest, waypoint: {ns, ew - amount}, pos: pos)
  end

  defp move(
         commands: [{command, amount} | rest],
         waypoint: waypoint,
         pos: pos
       )
       when command in [:left, :right] do
    count = rem(floor(amount / 90), 4)
    new_waypoint = move_waypoint(waypoint, command, count)
    move(commands: rest, waypoint: new_waypoint, pos: pos)
  end

  defp move(
         commands: [{:forward, amount} | rest],
         waypoint: {waypoint_ns, waypoint_ew},
         pos: {ns, ew}
       ) do
    pos = {amount * waypoint_ns + ns, amount * waypoint_ew + ew}
    move(commands: rest, waypoint: {waypoint_ns, waypoint_ew}, pos: pos)
  end

  defp move_waypoint(waypoint, _direction, 0), do: waypoint

  defp move_waypoint({ns, ew}, :right, count), do: move_waypoint({-ew, ns}, :right, count - 1)

  defp move_waypoint({ns, ew}, :left, count), do: move_waypoint({ew, -ns}, :left, count - 1)

  defp manhattan({ns, ew}), do: abs(ns) + abs(ew)

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

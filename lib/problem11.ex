defmodule Advent2020.Problem11 do
  def run(part) do
    seat_map = load()
    next_seat_map = flip_seats(part, seat_map)

    stabilize(part, next_seat_map, seat_map)
    |> Map.values()
    |> Enum.count(&(&1 == :occupied))
  end

  def load() do
    File.read('input11.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
    |> to_seat_map()
  end

  defp parse(line) do
    String.graphemes(line)
    |> Enum.map(fn char ->
      case char do
        "L" -> :empty
        "." -> :floor
      end
    end)
  end

  defp to_seat_map(lines) do
    Enum.with_index(lines)
    |> Enum.reduce(%{}, fn {line, y}, map ->
      Enum.with_index(line)
      |> Enum.reduce(map, fn {val, x}, map ->
        Map.put(map, {x, y}, val)
      end)
    end)
  end

  defp stabilize(_part, seat_map, prev_seat_map) when seat_map == prev_seat_map, do: seat_map

  defp stabilize(part, seat_map, _prev_seat_map) do
    next_seat_map = flip_seats(part, seat_map)
    stabilize(part, next_seat_map, seat_map)
  end

  defp flip_seats(part, seat_map) do
    Map.keys(seat_map)
    |> Enum.reduce(seat_map, fn pos, new_seat_map ->
      case flip(part, seat_map, pos) do
        nil -> new_seat_map
        val -> Map.put(new_seat_map, pos, val)
      end
    end)
  end

  defp flip(part, seat_map, pos), do: flip(part, seat_map, pos, Map.get(seat_map, pos))
  def flip(_part, _seat_map, _pos, state) when state in [nil, :floor], do: nil

  def flip(part, seat_map, pos, :empty) do
    adjacent(part, seat_map, pos)
    |> Enum.any?(&(Map.get(seat_map, &1) == :occupied))
    |> case do
      true ->
        nil

      false ->
        :occupied
    end
  end

  def flip(part, seat_map, pos, :occupied) do
    adjacent_occupied =
      adjacent(part, seat_map, pos)
      |> Enum.count(&(Map.get(seat_map, &1) == :occupied))

    tolerance = (part == :part1 && 4) || 5

    if adjacent_occupied >= tolerance do
      :empty
    else
      nil
    end
  end

  defp adjacent(:part1, _seat_map, {x, y}) do
    Enum.flat_map([x - 1, x, x + 1], fn x ->
      Enum.map([y - 1, y, y + 1], fn y -> {x, y} end)
    end)
    |> Enum.reject(&(&1 == {x, y}))
  end

  defp adjacent(:part2, seat_map, {x, y}) do
    Enum.flat_map([-1, 0, 1], fn dx ->
      Enum.map([-1, 0, 1], fn dy ->
        if dx == 0 and dy == 0 do
          nil
        else
          fn {x, y} ->
            {x + dx, y + dy}
          end
        end
      end)
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.map(fn angle_fn ->
      pos = angle_fn.({x, y})
      process_angle(seat_map, pos, angle_fn)
    end)
    |> Enum.reject(&(&1 == nil))
  end

  defp process_angle(seat_map, pos, angle_fn),
    do: process_angle(seat_map, pos, angle_fn, Map.get(seat_map, pos))

  defp process_angle(_seat_map, _pos, _angle_fn, nil), do: nil

  defp process_angle(seat_map, pos, angle_fn, :floor) do
    next_pos = angle_fn.(pos)
    process_angle(seat_map, next_pos, angle_fn)
  end

  defp process_angle(_seat_map, pos, _angle_fn, _state), do: pos

  defp print_seat_map(seat_map) do
    {all_x, all_y} =
      Map.keys(seat_map)
      |> Enum.unzip()

    max_x = Enum.max(all_x)
    max_y = Enum.max(all_y)

    IO.inspect("============")

    for y <- 0..max_y do
      row =
        Enum.map(0..max_x, &Map.fetch!(seat_map, {&1, y}))
        |> Enum.map(fn state ->
          case state do
            :empty -> "L"
            :floor -> "."
            :occupied -> "#"
          end
        end)

      IO.inspect(row)
    end

    IO.inspect("============")
  end
end

defmodule Advent2020.Problem15 do
  def run(:part1) do
    nums = load()
    {map, last_num} = initialize(nums)
    play(map: map, last_num: last_num, turn: Enum.count(nums) + 1)
  end

  def load() do
    File.read('input15.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
    |> hd()
  end

  defp initialize(nums) do
    last_num = List.last(nums)

    map =
      Enum.with_index(nums)
      |> Enum.into(%{}, fn {val, index} -> {val, {index + 1, nil}} end)

    {map, last_num}
  end

  defp play(map: _map, last_num: last_num, turn: 2021), do: last_num

  defp play(map: map, last_num: last_num, turn: turn) do
    next_num =
      case Map.fetch!(map, last_num) do
        {_val, nil} ->
          0

        {newer, older} ->
          newer - older
      end

    map = Map.update(map, next_num, {turn, nil}, fn {newer, _older} -> {turn, newer} end)
    play(map: map, last_num: next_num, turn: turn + 1)
  end

  defp parse(line) do
    String.split(line, ",")
    |> Enum.map(&to_int(&1))
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

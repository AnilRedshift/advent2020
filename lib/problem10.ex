defmodule Advent2020.Problem10 do
  def run(:part1) do
    counts =
      load()
      |> Enum.reduce({0, %{1 => 0, 2 => 0, 3 => 0}}, fn elem, {prev, counts} ->
        gap = elem - prev
        counts = Map.update(counts, gap, 0, &(&1 + 1))
        {elem, counts}
      end)
      |> elem(1)
      |> Map.update(3, 0, &(&1 + 1))

    Map.fetch!(counts, 1) * Map.fetch!(counts, 3)
  end

  def run(:part2) do
    nums =
      load()
      |> List.insert_at(0, 0)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {val, index} -> {index, val} end)

    count_ways(nums: nums, index: 0, cache: %{})
    |> Map.fetch!(0)
  end

  def load() do
    File.read('input10.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&to_int/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end

  defp count_ways(nums: _nums, index: index, cache: cache)
       when :erlang.is_map_key(index, cache) do
    cache
  end

  defp count_ways(nums: nums, index: index, cache: cache) when index >= map_size(nums) do
    cache
  end

  defp count_ways(nums: nums, index: index, cache: cache) when index + 1 == map_size(nums) do
    Map.put(cache, index, 1)
  end

  defp count_ways(nums: nums, index: index, cache: cache) do
    num = Map.fetch!(nums, index)

    next_possible_indices =
      Enum.take_while((index + 1)..(map_size(nums) - 1), fn next_index ->
        Map.fetch!(nums, next_index) <= num + 3
      end)

    cache =
      Enum.reduce(next_possible_indices, cache, fn next_index, cache ->
        count_ways(nums: nums, index: next_index, cache: cache)
      end)

    possible_ways =
      Enum.reduce(next_possible_indices, 0, fn next_index, sum ->
        sum + Map.fetch!(cache, next_index)
      end)

    Map.put(cache, index, possible_ways)
  end
end

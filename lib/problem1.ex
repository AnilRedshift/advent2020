defmodule Advent2020.Problem1 do
  def run(:part1) do
    load()
    |> two_sum(2020)
    |> case do
      nil -> nil
      {a, b} -> a * b
    end
  end

  def run(:part2) do
    load()
    |> three_sum(2020)
    |> case do
      nil ->
        nil

      {a, b, c} ->
        a * b * c
    end
  end

  def load() do
    File.read('input1.txt')
    |> elem(1)
    |> String.split()
    |> Advent2020.Parser.parse_as_integers()
    |> list_to_counts()
  end

  def list_to_counts(nums) do
    Enum.reduce(nums, %{}, fn num, counts ->
      Map.update(counts, num, 1, &(&1 + 1))
    end)
  end

  def two_sum(counts, target) do
    Enum.find(Map.keys(counts), nil, fn num ->
      if num == target / 2 do
        Map.get(counts, num, 0) > 1
      else
        Map.has_key?(counts, target - num)
      end
    end)
    |> case do
      nil -> nil
      val -> {val, target - val}
    end
  end

  def three_sum(counts, target) do
    Enum.find_value(counts, nil, fn {num, count} ->
      case count do
        1 -> Map.delete(counts, count)
        _ -> Map.update!(counts, num, &(&1 - 1))
      end
      |> two_sum(target - num)
      |> case do
        nil -> nil
        {a, b} -> {a, b, target - a - b}
      end
    end)
  end
end

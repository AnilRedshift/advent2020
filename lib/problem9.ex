defmodule Advent2020.Problem9 do
  def run(:part1) do
    {preamble, prev, input} = load()
    process(preamble, prev, input)
  end

  def run(:part2) do
    {preamble, prev, input} = load()
    target = process(preamble, prev, input)

    result =
      find_target(target: target, nums: prev ++ input, prev: [], prev_sum: 0)
      |> Enum.sort()

    smallest = hd(result)
    largest = Enum.reverse(result) |> hd()
    smallest + largest
  end

  def load() do
    {prev, input} =
      File.read('input9.txt')
      |> elem(1)
      |> String.split("\n")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&to_int/1)
      |> Enum.split(25)

    preamble = MapSet.new(prev)
    {preamble, prev, input}
  end

  defp process(_preamble, _prev, []), do: nil

  defp process(preamble, prev, [num | rest]) do
    if is_valid?(preamble, num) do
      [to_pop | prev_rest] = prev
      new_prev = prev_rest ++ [num]

      MapSet.delete(preamble, to_pop)
      |> MapSet.put(num)
      |> process(new_prev, rest)
    else
      num
    end
  end

  defp is_valid?(preamble, num) do
    result =
      Enum.find(preamble, nil, fn preamble_num ->
        MapSet.member?(preamble, num - preamble_num)
      end)

    result != nil
  end

  def find_target(target: target, nums: _nums, prev: prev, prev_sum: prev_sum)
      when prev_sum == target,
      do: prev

  def find_target(target: _target, nums: [], prev: _prev, prev_sum: _prev_sum), do: :not_found

  def find_target(target: target, nums: nums, prev: prev, prev_sum: prev_sum)
      when prev_sum < target do
    find_target(
      target: target,
      nums: tl(nums),
      prev: prev ++ [hd(nums)],
      prev_sum: prev_sum + hd(nums)
    )
  end

  def find_target(target: target, nums: nums, prev: prev, prev_sum: prev_sum) do
    find_target(target: target, nums: nums, prev: tl(prev), prev_sum: prev_sum - hd(prev))
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

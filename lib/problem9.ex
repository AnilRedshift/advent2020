defmodule Advent2020.Problem9 do
  def run(:part1) do
    {preamble, prev, input} = load()
    process(preamble, prev, input)
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

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

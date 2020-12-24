defmodule Advent2020.Problem23 do
  alias Advent2020.LinkedMap

  def run(:part1) do
    cups =
      load()
      |> LinkedMap.new()

    max = Enum.max(cups)

    {tail, [1 | start]} =
      play(%{cups: cups, max: max, round: 0, num_rounds: 100})
      |> Enum.split_while(&(&1 != 1))

    Integer.undigits(start ++ tail)
  end

  def run(:part2) do
    initial_cups = load()
    initial_max = Enum.max(initial_cups)

    cups =
      Stream.concat(initial_cups, (initial_max + 1)..1_000_000)
      |> LinkedMap.new()

    cups = play(%{cups: cups, max: 1_000_000, round: 0, num_rounds: 10_000_000})

    [_, a, b] =
      %LinkedMap{cups | head: 1}
      |> Enum.take(3)

    a * b
  end

  def load() do
    File.read('input23.txt')
    |> elem(1)
    |> String.split("")
    |> Enum.reject(&(&1 == "\n" || &1 == ""))
    |> Enum.map(&to_int(&1))
  end

  defp play(%{cups: cups, round: round, num_rounds: num_rounds}) when round == num_rounds do
    cups
  end

  defp play(%{cups: cups, max: max, round: round} = args) do
    if rem(round, 100_000) == 0 do
      IO.inspect("round #{round}")
    end

    [cup | to_move] = Enum.take(cups, 4)
    destination = get_destination(cup: cup, to_move: to_move, max: max)

    cups =
      Enum.reduce(to_move, cups, fn cup, cups ->
        LinkedMap.delete(cups, cup)
      end)

    cups =
      Enum.reverse(to_move)
      |> Enum.reduce(cups, fn
        cup, cups -> LinkedMap.insert_after(cups, destination, cup)
      end)
      |> LinkedMap.delete(cup)
      |> LinkedMap.append(cup)

    play(%{args | cups: cups, round: round + 1})
  end

  defp get_destination(cup: cup, to_move: to_move, max: max) when cup == 1 do
    get_destination(cup: max + 1, to_move: to_move, max: max)
  end

  defp get_destination(cup: cup, to_move: to_move, max: max) do
    if (cup - 1) in to_move do
      get_destination(cup: cup - 1, to_move: to_move, max: max)
    else
      cup - 1
    end
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

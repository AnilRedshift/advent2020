defmodule Advent2020.Problem23 do
  def run(:part1) do
    cups = load()

    max = Enum.max(cups)
    cups = play(cups, %{num_moves: 100, max: max})

    {tail, [1 | nums]} = Enum.split_while(cups, &(&1 != 1))

    (nums ++ tail)
    |> Integer.undigits()
  end

  def run(:part2) do
    cups = load()
    next_num = Enum.max(cups) + 1
    remaining_cups = next_num..1_000_000 |> Enum.into([])
    cups = cups ++ remaining_cups
    max = Enum.max(cups)

    play(cups, %{num_moves: 10_000_000, max: max})
    {tail, [1 | nums]} = Enum.split_while(cups, &(&1 != 1))

    Stream.concat(nums, tail)
    |> Enum.take(2)
  end

  def load() do
    File.read('input23.txt')
    |> elem(1)
    |> String.split("")
    |> Enum.reject(&(&1 == "\n" || &1 == ""))
    |> Enum.map(&to_int(&1))
  end

  defp play(cups, %{num_moves: num_moves, move: move}) when num_moves == move do
    cups
  end

  defp play([cup | rest], %{max: max} = opts) do
    {to_move, remaining_cups} = Enum.split(rest, 3)

    destination = get_destination(cup: cup, to_move: to_move, max: max)

    {before_split, [^destination | after_split]} =
      Enum.split_while(remaining_cups, &(&1 != destination))

    opts = Map.update(opts, :move, 1, &(&1 + 1))

    (before_split ++ [destination | to_move] ++ after_split ++ [cup])
    |> play(opts)
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

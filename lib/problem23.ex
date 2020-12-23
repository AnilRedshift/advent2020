defmodule Advent2020.Problem23 do
  def run(:part1) do
    cups =
      load()
      |> play(0)

    {tail, [1 | nums]} = Enum.split_while(cups, &(&1 != 1))

    (nums ++ tail)
    |> Integer.undigits()
  end

  def load() do
    File.read('input23.txt')
    |> elem(1)
    |> String.split("")
    |> Enum.reject(&(&1 == "\n" || &1 == ""))
    |> Enum.map(&to_int(&1))
  end

  defp play(cups, 100) do
    cups
  end

  defp play([cup | rest] = cups, round) do
    {to_move, remaining_cups} = Enum.split(rest, 3)
    destination = get_destination(cups: cups, cup: cup, to_move: to_move)

    {before_split, [^destination | after_split]} =
      Enum.split_while(remaining_cups, &(&1 != destination))

    (before_split ++ [destination | to_move] ++ after_split ++ [cup])
    |> play(round + 1)
  end

  defp get_destination(cups: cups, cup: cup, to_move: to_move) when cup == 1 do
    cup = Enum.max(cups) + 1
    get_destination(cups: cups, cup: cup, to_move: to_move)
  end

  defp get_destination(cups: cups, cup: cup, to_move: to_move) do
    if (cup - 1) in to_move do
      get_destination(cups: cups, cup: cup - 1, to_move: to_move)
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

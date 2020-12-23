defmodule Advent2020.Problem22 do
  def run(:part1) do
    {player1, player2} = load()

    play(player1, player2)
    |> score()
  end

  def load() do
    [player1, player2] =
      File.read('input22.txt')
      |> elem(1)
      |> String.split("\n\n")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&parse/1)

    {player1, player2}
  end

  defp parse(line) do
    [_name | nums] =
      String.split(line, "\n")
      |> Enum.reject(&(&1 == ""))

    Enum.map(nums, &to_int(&1))
  end

  defp play(player1, []), do: player1
  defp play([], player2), do: player2

  defp play([card1 | player1], [card2 | player2]) when card1 > card2 do
    play(player1 ++ [card1, card2], player2)
  end

  defp play([card1 | player1], [card2 | player2]) when card2 > card1 do
    play(player1, player2 ++ [card2, card1])
  end

  defp score(deck) do
    Enum.reverse(deck)
    |> Enum.with_index(1)
    |> Enum.map(fn {val, index} -> val * index end)
    |> Enum.sum()
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

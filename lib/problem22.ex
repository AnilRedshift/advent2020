defmodule Advent2020.Problem22 do
  def run(:part1) do
    {player1, player2} = load()

    play(player1, player2)
    |> elem(1)
    |> score()
  end

  def run(:part2) do
    {player1, player2} = load()

    play_recursive(player1: player1, player2: player2, prev_rounds: MapSet.new())
    |> elem(1)
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

  defp play(player1, []), do: {:player1, player1}
  defp play([], player2), do: {:player2, player2}

  defp play([card1 | player1], [card2 | player2]) when card1 > card2 do
    play(player1 ++ [card1, card2], player2)
  end

  defp play([card1 | player1], [card2 | player2]) when card2 > card1 do
    play(player1, player2 ++ [card2, card1])
  end

  defp play_recursive(player1: [], player2: player2, prev_rounds: _) do
    {:player2, player2}
  end

  defp play_recursive(player1: player1, player2: [], prev_rounds: _) do
    {:player1, player1}
  end

  defp play_recursive(
         player1: [card1 | rest1] = player1,
         player2: [card2 | rest2] = player2,
         prev_rounds: prev_rounds
       ) do
    next_rounds = MapSet.put(prev_rounds, {player1, player2})

    cond do
      {player1, player2} in prev_rounds ->
        {:player1, player1}

      Enum.count(rest1) >= card1 and Enum.count(rest2) >= card2 ->
        player1_sub_cards = Enum.take(rest1, card1)
        player2_sub_cards = Enum.take(rest2, card2)

        play_recursive(
          player1: player1_sub_cards,
          player2: player2_sub_cards,
          prev_rounds: next_rounds
        )
        |> case do
          {:player1, _} ->
            play_recursive(
              player1: rest1 ++ [card1, card2],
              player2: rest2,
              prev_rounds: next_rounds
            )

          {:player2, _} ->
            play_recursive(
              player1: rest1,
              player2: rest2 ++ [card2, card1],
              prev_rounds: next_rounds
            )
        end

      card1 > card2 ->
        play_recursive(
          player1: rest1 ++ [card1, card2],
          player2: rest2,
          prev_rounds: next_rounds
        )

      card2 > card1 ->
        play_recursive(
          player1: rest1,
          player2: rest2 ++ [card2, card1],
          prev_rounds: next_rounds
        )
    end
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

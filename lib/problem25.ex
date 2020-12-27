defmodule Advent2020.Problem25 do
  def run(:part1) do
    public_keys = load()
    loop_counts = Enum.map(public_keys, &crack(&1, 7))

    [encryption_key, encryption_key] =
      Enum.zip(public_keys, Enum.reverse(loop_counts))
      |> Enum.map(fn {public_key, other_loop_count} ->
        transform(public_key, other_loop_count)
      end)

    encryption_key
  end

  def load() do
    File.read('input25.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  def parse(line) do
    to_int(line)
  end

  defp transform_step(prev_transform, subject_number) do
    rem(prev_transform * subject_number, 20_201_227)
  end

  defp transform(subject_number, loop_size) do
    Enum.reduce(0..(loop_size - 1), 1, fn _, prev_transform ->
      transform_step(prev_transform, subject_number)
    end)
  end

  defp crack(public_key, subject_number) do
    Enum.reduce_while(1..100_000_000, 1, fn loop_count, prev_transform ->
      val = transform_step(prev_transform, subject_number)

      if val == public_key do
        {:halt, {:ok, loop_count}}
      else
        {:cont, val}
      end
    end)
    |> case do
      {:ok, val} -> val
      _ -> :error
    end
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

defmodule Advent2020.Problem14 do
  def run(:part1) do
    commands = load()

    execute(commands: commands, bitmask: nil, mem: %{})
    |> Map.values()
    |> Enum.sum()
  end

  def load() do
    File.read('input14.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  def execute(commands: [], bitmask: _bitmask, mem: mem), do: mem

  def execute(commands: [{:mask, new_bitmask} | rest], bitmask: _bitmask, mem: mem) do
    execute(commands: rest, bitmask: new_bitmask, mem: mem)
  end

  def execute(commands: [{:write, {address, value}} | rest], bitmask: bitmask, mem: mem) do
    value = apply_bitmask(bitmask, value)
    mem = Map.put(mem, address, value)
    execute(commands: rest, bitmask: bitmask, mem: mem)
  end

  def apply_bitmask(bitmask, value) do
    bitmask_padding = Stream.cycle([:x]) |> Stream.take(36)
    value_padding = Stream.cycle([0]) |> Stream.take(36)

    reverse_bitmask = Enum.reverse(bitmask) |> Stream.concat(bitmask_padding)
    reverse_bits = Integer.digits(value, 2) |> Enum.reverse() |> Stream.concat(value_padding)

    Enum.zip(reverse_bits, reverse_bitmask)
    |> Enum.map(fn
      {bit, :x} -> bit
      {_bit, val} -> val
    end)
    |> Enum.reverse()
    |> Enum.join()
    |> to_int(2)
  end

  defp parse("mask = " <> binary) do
    values =
      String.graphemes(binary)
      |> Enum.map(fn char ->
        case char do
          "1" -> 1
          "0" -> 0
          "X" -> :x
          any -> raise ArgumentError, message: "Cannot parse #{any} in #{binary}"
        end
      end)

    {:mask, values}
  end

  defp parse("mem" <> binary) do
    Regex.run(~r/^\[(\d+)\] = (\d+)$/, binary)
    |> case do
      nil -> raise ArgumentError, message: "Cannot parse #{binary}"
      [_, address, value] -> {:write, {to_int(address), to_int(value)}}
    end
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

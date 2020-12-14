defmodule Advent2020.Problem14 do
  def run(part) do
    commands = load()

    execute(part: part, commands: commands, bitmask: nil, mem: %{})
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

  def execute(part: _part, commands: [], bitmask: _bitmask, mem: mem), do: mem

  def execute(part: part, commands: [{:mask, new_bitmask} | rest], bitmask: _bitmask, mem: mem) do
    execute(part: part, commands: rest, bitmask: new_bitmask, mem: mem)
  end

  def execute(
        part: :part1,
        commands: [{:write, {address, value}} | rest],
        bitmask: bitmask,
        mem: mem
      ) do
    value = apply_bitmask(:part1, bitmask, value)
    mem = Map.put(mem, address, value)
    execute(part: :part1, commands: rest, bitmask: bitmask, mem: mem)
  end

  def execute(
        part: :part2,
        commands: [{:write, {address, value}} | rest],
        bitmask: bitmask,
        mem: mem
      ) do
    addresses = apply_bitmask(:part2, bitmask, address)
    mem = Enum.reduce(addresses, mem, fn address, mem -> Map.put(mem, address, value) end)
    execute(part: :part2, commands: rest, bitmask: bitmask, mem: mem)
  end

  def apply_bitmask(:part1, bitmask, value) do
    bitmask_padding = Stream.cycle([:x])
    value_padding = Stream.cycle([0])

    reverse_bitmask =
      Enum.reverse(bitmask)
      |> Stream.concat(bitmask_padding)
      |> Stream.take(36)

    reverse_bits =
      Integer.digits(value, 2)
      |> Enum.reverse()
      |> Stream.concat(value_padding)
      |> Stream.take(36)

    Enum.zip(reverse_bits, reverse_bitmask)
    |> Enum.map(fn
      {_bit, 0} -> 0
      {_bit, 1} -> 1
      {bit, :x} -> bit
    end)
    |> Enum.reverse()
    |> Enum.join()
    |> to_int(2)
  end

  def apply_bitmask(:part2, bitmask, address) do
    bitmask_padding = Stream.cycle([0])
    address_padding = Stream.cycle([0])

    reverse_bitmask =
      Enum.reverse(bitmask)
      |> Stream.concat(bitmask_padding)
      |> Stream.take(36)

    reverse_bits =
      Integer.digits(address, 2)
      |> Enum.reverse()
      |> Stream.concat(address_padding)
      |> Stream.take(36)

    reverse_address_with_mask =
      Enum.zip(reverse_bits, reverse_bitmask)
      |> Enum.map(fn
        {bit, 0} -> bit
        {_bit, 1} -> 1
        {_bit, :x} -> :x
      end)

    Enum.reduce(reverse_address_with_mask, [[]], fn
      :x, addresses ->
        with_zeros = Enum.map(addresses, &[0 | &1])
        with_ones = Enum.map(addresses, &[1 | &1])
        with_zeros ++ with_ones

      val, addresses ->
        Enum.map(addresses, &[val | &1])
    end)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&to_int(&1, 2))
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

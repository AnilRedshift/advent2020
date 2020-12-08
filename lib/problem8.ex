defmodule Advent2020.Problem8 do
  def run(:part1) do
    program = load()
    execute(program: program, index: 0, acc: 0, lines_run: MapSet.new())
  end

  def load() do
    File.read('input8.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn line ->
      [command, amount] = String.split(line)
      {command, to_int(amount)}
    end)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {x, y} -> {y, x} end)
  end

  defp execute(program: program, index: index, acc: acc, lines_run: lines_run) do
    if MapSet.member?(lines_run, index) do
      acc
    else
      instruction = Map.fetch!(program, index)

      run_instruction(
        program: program,
        instruction: instruction,
        index: index,
        acc: acc,
        lines_run: MapSet.put(lines_run, index)
      )
    end
  end

  defp run_instruction(
         program: program,
         instruction: instruction,
         index: index,
         acc: acc,
         lines_run: lines_run
       ) do
    case instruction do
      {"acc", amount} ->
        execute(program: program, index: index + 1, acc: acc + amount, lines_run: lines_run)

      {"jmp", amount} ->
        execute(program: program, index: index + amount, acc: acc, lines_run: lines_run)

      {"nop", _amount} ->
        execute(program: program, index: index + 1, acc: acc, lines_run: lines_run)
    end
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

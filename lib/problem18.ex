defmodule Advent2020.Problem18 do
  def run(:part1) do
    load()
    |> Enum.map(&execute/1)
    |> Enum.sum()
  end

  def load() do
    File.read('input18.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  defp parse(line) do
    tokenize(line)
  end

  defp tokenize(""), do: []
  defp tokenize("(" <> rest), do: [:left_paren | tokenize(rest)]
  defp tokenize(")" <> rest), do: [:right_paren | tokenize(rest)]
  defp tokenize("+" <> rest), do: [:plus | tokenize(rest)]
  defp tokenize("*" <> rest), do: [:mul | tokenize(rest)]
  defp tokenize(" " <> rest), do: tokenize(rest)

  defp tokenize(line) do
    Regex.run(~r/^(\d+)(.*)$/, line)
    |> case do
      nil -> raise ArgumentError, message: "Cannot tokenize #{line}"
      [_line, num, rest] -> [{:num, to_int(num)} | tokenize(rest)]
    end
  end

  defp execute(commands), do: execute(commands, stack: [])

  defp execute([], stack: [{:result, result}]), do: result

  defp execute(commands, stack: [{:result, b}, {:plus, a} | stack]) do
    execute(commands, stack: [{:result, a + b} | stack])
  end

  defp execute(commands, stack: [{:result, b}, {:mul, a} | stack]) do
    execute(commands, stack: [{:result, a * b} | stack])
  end

  defp execute([{:num, b} | rest], stack: [{:plus, a} | stack]) do
    execute(rest, stack: [{:result, a + b} | stack])
  end

  defp execute([{:num, b} | rest], stack: [{:mul, a} | stack]) do
    execute(rest, stack: [{:result, a * b} | stack])
  end

  defp execute([{:num, num}, operand | rest], stack: stack) when operand in [:plus, :mul] do
    execute(rest, stack: [{operand, num} | stack])
  end

  defp execute([operand | rest], stack: [{:result, result} | stack])
       when operand in [:plus, :mul] do
    execute(rest, stack: [{operand, result} | stack])
  end

  defp execute([:left_paren | rest], stack: stack) do
    execute(rest, stack: [:left_paren | stack])
  end

  defp execute([:right_paren | rest], stack: [:left_paren | stack]) do
    execute(rest, stack: stack)
  end

  defp execute([:right_paren | rest], stack: [{:result, result}, :left_paren | stack]) do
    execute(rest, stack: [{:result, result} | stack])
  end

  defp execute([{:num, num} | rest], stack: stack) do
    execute(rest, stack: [{:result, num} | stack])
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end
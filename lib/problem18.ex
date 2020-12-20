defmodule Advent2020.Problem18 do
  def run(part) do
    lines = load()

    Enum.map(lines, &execute(%{tokens: &1, part: part}))
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

  defp execute(args) do
    # IO.inspect(Map.get(args, :stack, []))

    Map.merge(%{is_unbalanced: false, stack: []}, args)
    |> execute_internal()
  end

  defp execute_internal(%{tokens: [], stack: [num: result]}), do: result

  defp execute_internal(%{tokens: [], stack: stack, is_unbalanced: true} = args) do
    # If we got to the end without balancing parens, then they all belong at the end

    right_parens = for {:left_paren, :unbalanced} <- stack, do: :right_paren

    stack =
      Enum.map(stack, fn
        {:left_paren, :unbalanced} -> {:left_paren, :balanced}
        a -> a
      end)

    Map.merge(args, %{tokens: right_parens, stack: stack, is_unbalanced: false})
    |> execute()
  end

  defp execute_internal(
         %{
           stack: [{:num, b}, {:plus, a} | remaining_stack]
         } = args
       ) do
    # When the stack contains +3, and we just put on 4 to the stack, reduce the stack
    Map.merge(args, %{stack: [{:num, a + b} | remaining_stack]})
    |> execute()
  end

  defp execute_internal(
         %{
           tokens: [operand | _],
           stack: [{:num, b}, {:mul, a} | remaining_stack]
         } = args
       )
       when operand != :plus do
    # When the stack contains *3, and we just put on 4 to the stack, reduce the stack
    Map.merge(args, %{stack: [{:num, a * b} | remaining_stack]})
    |> execute()
  end

  defp execute_internal(
         %{
           tokens: [],
           stack: [{:num, b}, {:mul, a} | remaining_stack]
         } = args
       ) do
    # When the very last command is 3 * 4, it's safe to execute
    Map.merge(args, %{stack: [{:num, a * b} | remaining_stack]})
    |> execute()
  end

  defp execute_internal(%{tokens: [:left_paren | remaining_tokens], stack: stack} = args) do
    # New left-parens push the stack down, e.g (4
    Map.merge(args, %{tokens: remaining_tokens, stack: [{:left_paren, :balanced} | stack]})
    |> execute()
  end

  defp execute_internal(
         %{
           tokens: [:right_paren | remaining_tokens],
           stack: [{:num, num}, {:left_paren, :balanced} | remaining_stack]
         } = args
       ) do
    # When the stack contains (4 and we get a closing right paren, turn (4) -> 4
    Map.merge(args, %{tokens: remaining_tokens, stack: [{:num, num} | remaining_stack]})
    |> execute()
  end

  defp execute_internal(
         %{
           tokens: [{:num, num}, :plus | remaining_tokens],
           stack: [{:mul, _} | _] = stack,
           part: :part2
         } = args
       ) do
    # For 3 * 4 + 1, and we have :mul, 3 in the stack, we don't want to add 4 here, since that has precedence
    # Instead, insert a paren, so it becomes 3 * (4 +
    Map.merge(args, %{
      tokens: remaining_tokens,
      stack: [{:plus, num}, {:left_paren, :unbalanced} | stack],
      is_unbalanced: true
    })
    |> execute()
  end

  defp execute_internal(
         %{
           tokens: [operand | _],
           stack: [{:num, num}, {:left_paren, :unbalanced} | remaining_stack],
           is_unbalanced: true
         } = args
       )
       when operand in [:mul, :right_paren] do
    # We've found a place to insert a right paren to balance out a previous left paren
    # E.g. 1 * 2 + 3 * 4 -> becomes [num: 5 ,mul: 1] after the 2 + 3. When we see the next *, we can capture the 1 * 5
    is_unbalanced = Enum.any?(remaining_stack, &(&1 == {:left_paren, :unbalanced}))

    Map.merge(args, %{stack: [{:num, num} | remaining_stack], is_unbalanced: is_unbalanced})
    |> execute()
  end

  defp execute_internal(
         %{tokens: [operand | remaining_tokens], stack: [{:num, num} | remaining_stack]} = args
       )
       when operand in [:plus, :mul] do
    # When the token is + or *, and the stack contains the LHV, bind them together. E.g 3 + becomes {:plus, 3}
    Map.merge(args, %{tokens: remaining_tokens, stack: [{operand, num} | remaining_stack]})
    |> execute()
  end

  defp execute_internal(%{tokens: [{:num, num} | remaining_tokens], stack: stack} = args) do
    Map.merge(args, %{tokens: remaining_tokens, stack: [{:num, num} | stack]})
    |> execute()
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

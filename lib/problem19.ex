defmodule Advent2020.Problem19 do
  def run(:part1) do
    {rules, messages} = load()
    Enum.count(messages, &validate_message(&1, rules))
  end

  def load() do
    [rules, messages] =
      File.read('input19.txt')
      |> elem(1)
      |> String.split("\n\n")
      |> Enum.reject(&(&1 == ""))

    {parse_rules(rules), parse_messages(messages)}
  end

  defp parse_rules(line) do
    String.split(line, "\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn rule ->
      case Regex.run(~r/^(\d+): (.*)$/, rule) do
        nil -> raise ArgumentError, message: "Cannot find the index for #{rule}"
        [_, index, rest] -> {to_int(index), rest}
      end
    end)
    |> Enum.map(fn {index, rule} ->
      char_match = Regex.run(~r/^\"([a-zA-Z])\"$/, rule)

      parsed_rule =
        if char_match do
          [int_val] = Enum.at(char_match, 1) |> String.to_charlist()
          {:char, int_val}
        else
          vals =
            String.split(rule, "|")
            |> Enum.map(&String.split(&1, " "))
            |> Enum.map(fn sub_rule -> Enum.reject(sub_rule, &(&1 == "")) end)
            |> Enum.map(fn sub_rule -> Enum.map(sub_rule, &to_int(&1)) end)

          {:sub_rules, vals}
        end

      {index, parsed_rule}
    end)
    |> Enum.into(%{})
  end

  defp parse_messages(messages) do
    String.split(messages, "\n")
    |> Enum.reject(&(&1 == ""))
  end

  defp validate_message(message, rules) do
    case validate_message(message, rules, Map.fetch!(rules, 0)) do
      "" -> true
      nil -> false
      _remainder -> false
    end
  end

  defp validate_message("", _rules, _rule), do: ""

  defp validate_message(<<c::utf8>> <> remaining_message, _rules, {:char, char}) when c == char do
    # IO.inspect("validate char '#{char}' succeeded. remaining message is #{remaining_message}",
    #   binaries: :as_strings
    # )

    remaining_message
  end

  defp validate_message(message, _rules, {:char, c}) do
    # IO.inspect("Validate char '#{c}' for message #{message} FAILED", binaries: :as_strings)
    nil
  end

  defp validate_message(message, rules, {:sub_rules, sub_rules}) do
    # IO.inspect("validate sub_rules for #{message}")
    # IO.inspect(sub_rules, binaries: :as_strings)

    Enum.find_value(sub_rules, fn sub_rule ->
      Enum.reduce_while(sub_rule, message, fn index, message ->
        new_rule = Map.fetch!(rules, index)

        case validate_message(message, rules, new_rule) do
          :invalid -> {:halt, nil}
          remaining_message -> {:cont, remaining_message}
        end
      end)
    end)
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

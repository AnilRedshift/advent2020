defmodule Advent2020.Problem16 do
  def run(:part1) do
    {rules, _ticket, nearby_tickets} = load()

    all_ranges = Enum.flat_map(rules, &Keyword.fetch!(&1, :ranges))

    {_valid, invalid} = validate_nearby_tickets(rules, nearby_tickets)

    List.flatten(invalid)
    |> Enum.reject(fn ticket ->
      Enum.find(all_ranges, nil, fn {first, last} -> ticket >= first && ticket <= last end)
    end)
    |> Enum.sum()
  end

  def run(:part2) do
    {rules, your_ticket, nearby_tickets} = load()
    {valid_tickets, _invalid} = validate_nearby_tickets(rules, nearby_tickets)
    total_rules = Enum.count(rules)

    rules =
      Enum.map(rules, fn rule ->
        ranges = Keyword.fetch!(rule, :ranges)

        possible_indices =
          Enum.filter(0..(total_rules - 1), fn i ->
            values = Enum.map(valid_tickets, &Enum.at(&1, i))

            Enum.all?(values, fn value ->
              Enum.any?(ranges, fn {low, high} ->
                value >= low && value <= high
              end)
            end)
          end)

        Keyword.put(rule, :possible_indices, possible_indices)
      end)
      |> find_valid_indices()

    Enum.filter(rules, fn rule ->
      Keyword.fetch!(rule, :name) |> String.starts_with?("departure")
    end)
    |> Enum.map(&Keyword.fetch!(&1, :ticket_index))
    |> Enum.map(&Enum.at(your_ticket, &1))
    |> Enum.reduce(1, &(&1 * &2))
  end

  @spec load :: {[any], any, [any]}
  def load() do
    [rules, ticket, nearby_tickets] =
      File.read('input16.txt')
      |> elem(1)
      |> String.split("\n\n")
      |> Enum.reject(&(&1 == ""))

    rules = parse_rules(rules)
    ticket = parse_your_ticket(ticket)
    nearby_tickets = parse_nearby_tickets(nearby_tickets)
    {rules, ticket, nearby_tickets}
  end

  defp parse_rules(rules) do
    String.split(rules, "\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn rule ->
      case Regex.run(~r/^(.*): (\d+)-(\d+) or (\d+)-(\d+)$/, rule) do
        nil ->
          raise ArgumentError, message: "Cannot parse rule #{rule}"

        [_, name, low, high, low2, high2] ->
          [name: name, ranges: [{to_int(low), to_int(high)}, {to_int(low2), to_int(high2)}]]
      end
    end)
  end

  defp parse_nearby_tickets("nearby tickets:\n" <> nearby_tickets) do
    String.split(nearby_tickets, "\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn line ->
      String.split(line, ",")
      |> Enum.map(&to_int(&1))
    end)
  end

  defp parse_your_ticket("your ticket:\n" <> ticket) do
    String.split(ticket, ",")
    |> Enum.map(&to_int(&1))
  end

  defp validate_nearby_tickets(rules, nearby_tickets) do
    all_ranges = Enum.flat_map(rules, &Keyword.fetch!(&1, :ranges))

    Enum.split_with(nearby_tickets, fn nums ->
      Enum.all?(nums, fn num ->
        Enum.find(all_ranges, nil, fn {first, last} -> num >= first && num <= last end)
      end)
    end)
  end

  defp find_valid_indices(rules) do
    rule_index =
      Enum.find_index(rules, fn rule ->
        Keyword.fetch!(rule, :possible_indices)
        |> case do
          [val] -> val
          _ -> nil
        end
      end)

    if rule_index == nil do
      rules
    else
      rule = Enum.at(rules, rule_index)
      [index] = Keyword.fetch!(rule, :possible_indices)

      new_rule = Keyword.put(rule, :ticket_index, index)

      List.replace_at(rules, rule_index, new_rule)
      |> Enum.map(fn rule ->
        Keyword.update!(rule, :possible_indices, fn possible_indices ->
          Enum.reject(possible_indices, &(&1 == index))
        end)
      end)
      |> find_valid_indices()
    end
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

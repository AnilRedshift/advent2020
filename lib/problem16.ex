defmodule Advent2020.Problem16 do
  def run(:part1) do
    {rules, _ticket, nearby_tickets} = load()

    all_ranges = Enum.flat_map(rules, &Keyword.fetch!(&1, :ranges))

    List.flatten(nearby_tickets)
    |> Enum.reject(fn ticket ->
      Enum.find(all_ranges, nil, fn {first, last} -> ticket >= first && ticket <= last end)
    end)
    |> Enum.sum()
  end

  def load() do
    [rules, ticket, nearby_tickets] =
      File.read('input16.txt')
      |> elem(1)
      |> String.split("\n\n")
      |> Enum.reject(&(&1 == ""))

    rules = parse_rules(rules)
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

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

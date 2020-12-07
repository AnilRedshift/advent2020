defmodule Advent2020.Problem7 do
  def run(:part1) do
    load()
    |> contains_gold()
    |> Enum.count()
  end

  def load() do
    File.read('input7.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  def parse(line) do
    split = String.replace(line, "bags", "bag") |> String.split(" bag contain ")
    [bag, contains] = split

    contains =
      String.replace(contains, ".", "")
      |> String.split(",")
      |> Enum.map(fn sentence ->
        case sentence do
          "no other bag" ->
            :no_other_bags

          sentence ->
            match = Regex.run(~r/(?:\s*)(\d+) (.+)$/, sentence)

            if match == nil do
              raise "bad sentence #{sentence}"
            end

            [_, count, type] = match
            [count: count, type: type]
        end
      end)

    {bag <> " bag", contains}
  end

  def contains_gold(inputs) do
    {_leaves, rest} =
      Enum.split_with(inputs, fn {_bag, contains} -> match?([:no_other_bags], contains) end)

    contains(rest, MapSet.new(), ["shiny gold bag"])
  end

  defp contains(_rest, existing_colors, []), do: MapSet.delete(existing_colors, "shiny gold bag")

  defp contains(rest, existing_colors, new_colors) do
    existing_colors = MapSet.union(existing_colors, MapSet.new(new_colors))

    all_new_colors =
      Enum.map(new_colors, fn new_color ->
        matches =
          Enum.filter(rest, fn {_name, contains} ->
            Enum.any?(contains, fn [count: _count, type: type] -> type == new_color end)
          end)

        Enum.map(matches, &elem(&1, 0))
      end)
      |> List.flatten()
      |> MapSet.new()

    all_new_colors =
      MapSet.difference(all_new_colors, existing_colors)
      |> MapSet.to_list()

    contains(rest, existing_colors, all_new_colors)
  end
end

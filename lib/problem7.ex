defmodule Advent2020.Problem7 do
  def run(:part1) do
    load()
    |> contains_gold()
    |> Enum.count()
  end

  def run(:part2) do
    load()
    |> dag()
    |> sum_dag("shiny gold bag")
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
            [count: to_int(count), type: type]
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

  def dag(inputs) do
    {leaves, rest} =
      Enum.split_with(inputs, fn {_bag, contains} -> match?([:no_other_bags], contains) end)

    leaves =
      Enum.map(leaves, &elem(&1, 0))
      |> Enum.into([], &Map.new([{&1, [contains: %{}, is_root: true]}]))

    dag = Enum.reduce(leaves, %{}, &merge_dags/2)

    Enum.reduce(rest, dag, fn {name, contains}, dag ->
      new_children =
        Enum.into(contains, %{}, fn keywords ->
          name = Keyword.fetch!(keywords, :type)
          count = Keyword.fetch!(keywords, :count)
          {name, count}
        end)

      new_dag = Map.put(%{}, name, contains: new_children, is_root: true)

      new_dag =
        Enum.reduce(contains, new_dag, fn child, new_dag ->
          Map.put(new_dag, Keyword.fetch!(child, :type), contains: %{}, is_root: false)
        end)

      merge_dags(dag, new_dag)
    end)
  end

  defp merge_dags(dest, src) do
    roots =
      Enum.filter(src, fn {_key, keywords} -> Keyword.fetch!(keywords, :is_root) end)
      |> Enum.map(&elem(&1, 0))

    merge_dags(dest, src, roots)
  end

  defp merge_dags(dest, _src, []), do: dest

  defp merge_dags(dest, src, [src_root | roots]) do
    new_children = Map.fetch!(src, src_root) |> Keyword.fetch!(:contains)

    default_value = [contains: new_children, is_root: true]

    # Update the root value
    dest =
      Map.update(dest, src_root, default_value, fn keywords ->
        is_root = Keyword.fetch!(keywords, :is_root)
        existing_children = Keyword.fetch!(keywords, :contains)
        contains = Map.merge(existing_children, new_children, fn _k, v1, v2 -> v1 + v2 end)
        [contains: contains, is_root: is_root]
      end)

    # Update all the corresponding children
    dest =
      Enum.reduce(Map.keys(new_children), dest, fn child, dest ->
        default_value = [contains: %{}, is_root: false]
        Map.update(dest, child, default_value, &Keyword.put(&1, :is_root, false))
      end)

    merge_dags(dest, src, Map.keys(new_children) ++ roots)
  end

  defp sum_dag(dag, name) when not :erlang.is_map_key(name, dag),
    do: 0

  defp sum_dag(dag, name) do
    sum =
      Map.fetch!(dag, name)
      |> Keyword.fetch!(:contains)
      |> Enum.map(fn {k, count} -> count + count * sum_dag(dag, k) end)
      |> Enum.sum()

    sum
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

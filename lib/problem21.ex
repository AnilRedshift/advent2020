defmodule Advent2020.Problem21 do
  def run(:part1) do
    recipes = load()

    all_ingredients =
      Enum.flat_map(recipes, &elem(&1, 0))
      |> MapSet.new()

    mapping = get_mapping(recipes)

    possible_allergens =
      Map.values(mapping)
      |> Enum.reduce(MapSet.new(), &MapSet.union/2)

    non_allergens = MapSet.difference(all_ingredients, possible_allergens)

    Enum.map(recipes, fn {ingredients, _} ->
      MapSet.intersection(non_allergens, ingredients)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def run(:part2) do
    load()
    |> get_mapping()
    |> get_allergens()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.join(",")
  end

  def load() do
    File.read('input21.txt')
    |> elem(1)
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  defp parse(line) do
    case Regex.run(~r/^(.*)\(contains (.*)\)$/, line) do
      nil ->
        raise ArgumentError, message: "Cannot parse #{line}"

      [_, ingredients, allergens] ->
        ingredients =
          String.split(ingredients, " ")
          |> Enum.reject(&(&1 == ""))
          |> MapSet.new()

        allergens =
          String.split(allergens, ", ")
          |> Enum.reject(&(&1 == ""))

        {ingredients, allergens}
    end
  end

  defp get_mapping(recipes) do
    Enum.reduce(recipes, %{}, fn {ingredients, allergens}, mapping ->
      Enum.reduce(allergens, mapping, fn allergen, mapping ->
        Map.update(mapping, allergen, ingredients, &MapSet.intersection(&1, ingredients))
      end)
    end)
  end

  defp get_allergens(mapping) do
    Enum.map(mapping, fn {k, v} -> {k, MapSet.to_list(v)} end)
    |> get_allergens([])
    |> Enum.into(%{})
  end

  defp get_allergens([], allergens), do: allergens

  defp get_allergens(mapping, allergens) do
    Enum.find_value(mapping, fn
      {english, [elem]} -> {english, elem}
      _ -> nil
    end)
    |> case do
      nil ->
        raise ArgumentError, "Cannot find a single ingredient for #{mapping}"
        nil

      {english, translation} ->
        Enum.map(mapping, fn {key, ingredients} ->
          {key, Enum.reject(ingredients, &(&1 == translation))}
        end)
        |> Enum.reject(fn
          {_, []} -> true
          _ -> false
        end)
        |> get_allergens([{english, translation} | allergens])
    end
  end
end

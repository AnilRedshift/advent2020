defmodule Advent2020.Problem21 do
  def run(:part1) do
    recipes = load()

    all_ingredients =
      Enum.flat_map(recipes, &elem(&1, 0))
      |> MapSet.new()

    mapping =
      Enum.reduce(recipes, %{}, fn {ingredients, allergens}, mapping ->
        Enum.reduce(allergens, mapping, fn allergen, mapping ->
          Map.update(mapping, allergen, ingredients, &MapSet.intersection(&1, ingredients))
        end)
      end)

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
end

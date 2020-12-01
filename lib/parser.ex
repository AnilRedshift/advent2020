defmodule Advent2020.Parser do
  @spec parse_as_integers([String.t()]) :: [integer]
  def parse_as_integers(inputs) do
    trimmed_inputs = Enum.map(inputs, &String.trim/1)
    is_valid_fn = fn input -> Integer.parse(input) != :error end
    for input <- trimmed_inputs, is_valid_fn.(input), do: String.to_integer(input)
  end

  def parse_as_integer_array([input | _]) do
    parse_as_alphanumeric_array(input) |> parse_as_integers
  end

  def parse_as_alphanumeric_array(input) do
    String.split(input, ",") |> Enum.map(&String.trim/1)
  end

  def parse_as_alphanumeric_arrays(inputs), do: Enum.map(inputs, &parse_as_alphanumeric_array/1)
end

defmodule Advent2020.Problem4 do
  defmodule Passport do
    defstruct birth_year: nil,
              issue_year: nil,
              expiration_year: nil,
              height: nil,
              height_unit: nil,
              hair_color: nil,
              eye_color: nil,
              passport_id: nil,
              country_id: nil
  end

  def run(:part1) do
    load()
    |> Enum.map(&struct(&1, country_id: &1.country_id || "fake_country"))
    |> Enum.filter(fn passport = %Passport{} -> Map.values(passport) |> Enum.all?() end)
    |> Enum.count()
  end

  defp load() do
    File.read('input4.txt')
    |> elem(1)
    |> String.split("\n\n")
    |> Enum.map(&parse/1)
  end

  defp parse(line) do
    Regex.scan(~r/(\w+):(\S+)(?:\s|$)/, line)
    |> Enum.reduce(%Passport{}, fn [_, key, value], passport ->
      case key do
        "byr" ->
          struct(passport, birth_year: to_int(value))

        "iyr" ->
          struct(passport, issue_year: to_int(value))

        "eyr" ->
          struct(passport, expiration_year: to_int(value))

        "hgt" ->
          [_, value, unit] = Regex.run(~r/^(\d+)(\w+)$/, value)
          struct(passport, height: to_int(value), height_unit: unit)

        "hcl" ->
          struct(passport, hair_color: value)

        "ecl" ->
          struct(passport, eye_color: value)

        "pid" ->
          struct(passport, passport_id: value)

        "cid" ->
          struct(passport, country_id: to_int(value))
      end
    end)
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

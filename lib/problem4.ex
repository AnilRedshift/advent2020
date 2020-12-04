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

    def is_valid?(passport = %Passport{})
        when passport.birth_year < 1920 or passport.birth_year > 2002 or
               passport.issue_year < 2010 or passport.issue_year > 2020 or
               passport.expiration_year < 2020 or passport.expiration_year > 2030,
        do: false

    def is_valid?(passport = %Passport{})
        when passport.height_unit == "cm" and (passport.height < 150 or passport.height > 193),
        do: false

    def is_valid?(passport = %Passport{})
        when passport.height_unit == "in" and (passport.height < 59 or passport.height > 76),
        do: false

    def is_valid?(passport = %Passport{}) when passport.height_unit not in ["in", "cm"], do: false

    def is_valid?(passport = %Passport{})
        when passport.eye_color not in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"],
        do: false

    def is_valid?(passport = %Passport{}) do
      cond do
        Regex.match?(~r/^\d{9,9}$/, passport.passport_id) == false ->
          false

        Regex.match?(~r/^#(?:[0-9a-fA-F]){6,6}$/, passport.hair_color) == false ->
          false

        true ->
          is_valid?(passport, :only_nonnull)
      end
    end

    def is_valid?(passport = %Passport{}, :only_nonnull) do
      Map.values(passport) |> Enum.all?()
    end
  end

  def run(:part1) do
    load()
    |> Enum.map(&struct(&1, country_id: &1.country_id || "fake_country"))
    |> Enum.filter(&Passport.is_valid?(&1, :only_nonnull))
    |> Enum.count()
  end

  def run(:part2) do
    load()
    |> Enum.map(&struct(&1, country_id: &1.country_id || "fake_country"))
    |> Enum.filter(&Passport.is_valid?(&1, :only_nonnull))
    |> Enum.filter(&Passport.is_valid?/1)

    # |> Enum.count()
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

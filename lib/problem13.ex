defmodule Advent2020.Problem13 do
  @primes [
    2,
    3,
    5,
    7,
    11,
    13,
    19,
    23,
    29,
    31,
    37,
    41,
    43,
    47,
    53,
    59,
    61,
    67,
    71,
    73,
    79,
    83,
    89,
    97,
    101
  ]
  def run(:part1) do
    {timestamp, routes} = load()

    # timestamp = 10
    # route = 7
    # delay = 4
    # rem(10, 7) = 3
    # next route is (10 - 3) + 7 = 14
    # delay is 14 - 10 = 4
    # (timestamp - rem + route) - timestamp
    # -rem + route = -3 + 7 = 4

    {route, delay} =
      Enum.reject(routes, &(&1 == :no_route))
      |> Enum.map(fn route -> {route, route - rem(timestamp, route)} end)
      |> Enum.min_by(&elem(&1, 1))

    route * delay
  end

  def run(:part2) do
    {_, routes} = load()

    # For 3, 5 -> 9 is correct
    # 3x + 1 = 5y
    # There's some mod math to make this work...

    # For 7,13,x,x,59,x,31,19
    # idx 0, 1,2,3,4, 5, 6, 7
    # common denominator of (7, 12, 55, 25, 12)
    routes =
      routes
      |> Enum.with_index()
      |> Enum.reject(fn {route, _offset} -> route == :no_route end)

    first_route = hd(routes) |> elem(0)

    lcm =
      Enum.map(routes, fn {route, offset} -> route - offset end)
      |> Enum.map(&decompose/1)
      |> least_common_multiple()

    first_route * lcm
  end

  def load() do
    [timestamp, routes] =
      File.read('input13.txt')
      |> elem(1)
      |> String.split("\n")
      |> Enum.reject(&(&1 == ""))

    routes = parse(routes)

    {to_int(timestamp), routes}
  end

  defp parse(routes) do
    String.split(routes, ",")
    |> Enum.map(fn route ->
      (route == "x" && :no_route) || to_int(route)
    end)
  end

  def decompose(num) when num in [0, 1], do: %{}

  Enum.each(@primes, fn prime ->
    def decompose(num) when rem(num, unquote(prime)) == 0 do
      decompose(floor(num / unquote(prime)))
      |> Map.update(unquote(prime), 1, &(&1 + 1))
    end
  end)

  def least_common_multiple(decompositions), do: least_common_multiple(decompositions, %{})

  def least_common_multiple([], lcm) do
    Enum.reduce(lcm, 1, fn {prime, count}, lcm ->
      prime * count * lcm
    end)
  end

  def least_common_multiple([decomposition | rest], lcm) do
    lcm = Map.merge(lcm, decomposition, fn _key, a, b -> max(a, b) end)
    least_common_multiple(rest, lcm)
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

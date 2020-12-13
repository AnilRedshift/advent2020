defmodule Advent2020.Problem13 do
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
      Enum.map(routes, fn route -> {route, route - rem(timestamp, route)} end)
      |> Enum.min_by(&elem(&1, 1))

    route * delay
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
    |> Enum.reject(&(&1 == "x"))
    |> Enum.map(&to_int/1)
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end
end

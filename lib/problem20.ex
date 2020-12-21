defmodule Advent2020.Problem20 do
  @tile_length 10
  def run(:part1) do
    tiles = load()

    board_width = floor(:math.sqrt(Enum.count(tiles)))

    solve(tiles, %{}, board_width, 0, 0)
    |> case do
      nil ->
        nil

      grid ->
        [
          {0, 0},
          {board_width - 1, 0},
          {0, board_width - 1},
          {board_width - 1, board_width - 1}
        ]
        |> Enum.map(&Map.fetch!(grid, &1))
        |> Enum.map(&elem(&1, 0))
        |> Enum.sum()
    end
  end

  def load() do
    File.read('input20.txt')
    |> elem(1)
    |> String.split("\n\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
  end

  defp parse(entry) do
    [name_row | tile] =
      String.split(entry, "\n")
      |> Enum.reject(&(&1 == ""))

    "Tile " <> num = String.trim_trailing(name_row, ":")

    tile =
      Enum.with_index(tile)
      |> Enum.map(fn {row, y} ->
        String.graphemes(row)
        |> Enum.map(fn
          "#" -> true
          "." -> false
        end)
        |> Enum.with_index()
        |> Enum.map(fn {val, x} -> {{x, y}, val} end)
      end)
      |> List.flatten()
      |> Enum.into(%{})

    {to_int(num), tile}
  end

  defp to_int(val, base \\ 10) do
    case Integer.parse(val, base) do
      :error -> raise ArgumentError, message: "Cannot parse #{val} to integer"
      {int, _} -> int
    end
  end

  defp solve([], grid, _board_width, _x, _y), do: grid

  defp solve(tiles, grid, board_width, x, y) do
    Enum.find_value(tiles, fn {name, tile} ->
      get_valid_tiles(grid, tile, x, y)
      |> Enum.find_value(fn tile ->
        grid = Map.put(grid, {x, y}, {name, tile})
        tiles = Enum.reject(tiles, fn {n, _} -> name == n end)
        last_in_row = x == board_width - 1
        x = (last_in_row && 0) || x + 1
        y = (last_in_row && y + 1) || y
        solve(tiles, grid, board_width, x, y)
      end)
    end)
  end

  defp get_tile(grid, x, y) do
    case Map.get(grid, {x, y}) do
      nil -> nil
      {_name, tile} -> tile
    end
  end

  defp get_valid_tiles(grid, tile, x, y) do
    get_orientations(tile)
    |> Enum.filter(fn tile ->
      tile_to_left = get_tile(grid, x - 1, y)
      tile_to_right = get_tile(grid, x + 1, y)
      tile_above = get_tile(grid, x, y + 1)
      tile_below = get_tile(grid, x, y - 1)

      (!tile_to_left or can_connect(tile_to_left, tile, :right)) and
        (!tile_to_right or can_connect(tile_to_right, tile, :left)) and
        (!tile_above or can_connect(tile_above, tile, :bottom)) and
        (!tile_below or can_connect(tile_below, tile, :top))
    end)
  end

  defp get_orientations(tile) do
    Enum.reduce(0..3, [tile], fn _, [tile | tiles] ->
      new_tile = rotate_right(tile)
      [new_tile, tile | tiles]
    end)
    |> Enum.flat_map(fn tile ->
      [tile, flip(tile, :horizontal), flip(tile, :vertical)]
    end)
  end

  defp can_connect(tile1, tile2, :right) do
    Enum.all?(0..(@tile_length - 1), fn y ->
      Map.fetch!(tile1, {@tile_length - 1, y}) == Map.fetch!(tile2, {0, y})
    end)
  end

  defp can_connect(tile1, tile2, :left), do: can_connect(tile2, tile1, :right)

  defp can_connect(tile1, tile2, :top) do
    Enum.all?(0..(@tile_length - 1), fn x ->
      Map.fetch!(tile1, {x, 0}) == Map.fetch!(tile2, {x, @tile_length - 1})
    end)
  end

  defp can_connect(tile1, tile2, :bottom), do: can_connect(tile2, tile1, :top)

  def rotate_right(tile) do
    # abc
    # def
    # ghi

    # becomes
    # gda
    # heb
    # ifc
    for y <- (@tile_length - 1)..0 do
      for x <- 0..(@tile_length - 1) do
        Map.fetch!(tile, {x, y})
      end
    end
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      Enum.with_index(row)
      |> Enum.map(fn {val, x} -> {{x, y}, val} end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  def flip(tile, :horizontal) do
    Enum.into(tile, %{}, fn {{x, y}, val} ->
      new_x = @tile_length - 1 - x
      {{new_x, y}, val}
    end)

    # abc
    # def
    # ghi

    # becomes
    # cba
    # fed
    # ihg
  end

  def flip(tile, :vertical) do
    Enum.into(tile, %{}, fn {{x, y}, val} ->
      new_y = @tile_length - 1 - y
      {{x, new_y}, val}
    end)

    # abc
    # def
    # ghi

    # becomes
    # ghi
    # def
    # abc
  end
end

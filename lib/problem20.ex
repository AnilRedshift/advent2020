defmodule Advent2020.Problem20 do
  @tile_length 10

  def run(:part1) do
    encoded_tiles =
      load()
      |> Enum.map(fn {name, tile} ->
        {name, get_encoded_orientations(tile)}
      end)
      |> Enum.into(%{})

    encoding_map = create_encoding_map(encoded_tiles)

    top_left =
      find_possible_corners(
        encoded_tiles: encoded_tiles,
        encoding_map: encoding_map,
        pos: {:top, :left}
      )

    # Because you can rotate the tiles right, there are 4 identical permutations
    # Therefore, there should be 4 tiles that match the top left corner, which in
    # actuality are the 4 tiles for each corner
    if Enum.count(top_left) == 4 do
      Enum.map(top_left, &elem(&1, 0))
      |> Enum.reduce(fn a, b -> a * b end)
    else
      nil
    end
  end

  def run(:part2) do
    encoded_tiles =
      load()
      |> Enum.map(fn {name, tile} ->
        {name, get_encoded_orientations(tile)}
      end)
      |> Enum.into(%{})

    encoding_map = create_encoding_map(encoded_tiles)

    top_left =
      find_possible_corners(
        encoded_tiles: encoded_tiles,
        encoding_map: encoding_map,
        pos: {:top, :left}
      )
      # To match up with the sample input of 1951
      |> Enum.at(1)

    grid = %{{0, 0} => top_left}
    remaining_tiles = Map.delete(encoded_tiles, elem(top_left, 0))
    board_length = Enum.count(encoded_tiles) |> :math.sqrt() |> floor()

    solve(%{
      remaining_tiles: remaining_tiles,
      grid: grid,
      encoding_map: encoding_map,
      board_length: board_length,
      pos: {1, 0}
    })
  end

  defp solve(%{
         grid: grid,
         board_length: board_length,
         pos: {0, board_length}
       }) do
    grid
  end

  defp solve(%{
         remaining_tiles: remaining_tiles,
         grid: grid,
         encoding_map: encoding_map,
         board_length: board_length,
         pos: {x, y}
       }) do
    IO.inspect(grid)

    left_edge =
      Map.get(grid, {x - 1, y}, {nil, []})
      |> elem(1)
      |> Keyword.get(:right, nil)

    top_edge =
      Map.get(grid, {x, y - 1}, {nil, []})
      |> elem(1)
      |> Keyword.get(:bottom, nil)

    possible_tiles =
      find_matches(%{
        remaining_tiles: remaining_tiles,
        encoding_map: encoding_map,
        encoding: left_edge,
        direction: :left
      })

    possible_tiles =
      find_matches(%{
        remaining_tiles: possible_tiles,
        encoding_map: encoding_map,
        encoding: top_edge,
        direction: :top
      })

    Enum.find_value(possible_tiles, nil, fn {name, orientations} ->
      Enum.find_value(orientations, nil, fn orientation ->
        grid = Map.put(grid, {x, y}, {name, orientation})
        remaining_tiles = Map.delete(remaining_tiles, name)
        new_x = (x == board_length - 1 && 0) || x + 1
        new_y = (x == board_length - 1 && y + 1) || y

        solve(%{
          remaining_tiles: remaining_tiles,
          grid: grid,
          encoding_map: encoding_map,
          board_length: board_length,
          pos: {new_x, new_y}
        })
      end)
    end)
  end

  defp find_matches(%{encoding: nil, remaining_tiles: remaining_tiles}) do
    remaining_tiles
  end

  defp find_matches(%{
         remaining_tiles: remaining_tiles,
         encoding_map: encoding_map,
         encoding: encoding,
         direction: direction
       }) do
    Map.fetch!(encoding_map, encoding)
    |> Enum.map(fn
      name when :erlang.is_map_key(name, remaining_tiles) ->
        matching_orientations =
          Map.fetch!(remaining_tiles, name)
          |> Enum.filter(fn orientation ->
            Keyword.fetch!(orientation, direction) == encoding
          end)

        {name, matching_orientations}

      name ->
        {name, []}
    end)
    |> Enum.reject(fn
      {_, []} -> true
      _ -> false
    end)
    |> Enum.reduce(%{}, fn {name, orientations}, acc ->
      Map.update(acc, name, orientations, &(orientations ++ &1))
    end)
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

  defp get_orientations(tile) do
    Enum.reduce(1..3, [tile], fn _, [tile | tiles] ->
      new_tile = rotate_right(tile)
      [new_tile, tile | tiles]
    end)
    |> Enum.flat_map(fn tile ->
      [tile, flip(tile, :horizontal), flip(tile, :vertical)]
    end)
  end

  defp encode_tile(tile) do
    for i <- 0..(@tile_length - 1) do
      [
        top: Map.fetch!(tile, {i, 0}),
        bottom: Map.fetch!(tile, {i, @tile_length - 1}),
        left: Map.fetch!(tile, {0, i}),
        right: Map.fetch!(tile, {@tile_length - 1, i})
      ]
    end
    |> Enum.reverse()
    |> Enum.reduce(%{top: [], bottom: [], left: [], right: []}, fn row, acc ->
      Enum.reduce([:top, :bottom, :left, :right], acc, fn key, acc ->
        Map.update!(acc, key, fn vals -> [Keyword.fetch!(row, key) | vals] end)
      end)
    end)
    |> Enum.map(fn {direction, vals} ->
      encoding =
        Enum.map(vals, &((&1 && 1) || 0))
        |> Integer.undigits(2)

      {direction, encoding}
    end)
  end

  defp get_encoded_orientations(tile) do
    get_orientations(tile)
    |> Enum.map(&encode_tile/1)
    |> Enum.uniq()
  end

  defp create_encoding_map(encoded_tiles) do
    Enum.reduce(encoded_tiles, %{}, fn {name, orientations}, acc ->
      Enum.reduce(orientations, acc, fn orientation, acc ->
        Enum.unzip(orientation)
        |> elem(1)
        |> Enum.reduce(acc, fn encoding, acc ->
          Map.update(acc, encoding, MapSet.new([name]), &MapSet.put(&1, name))
        end)
      end)
    end)
  end

  defp find_possible_corners(
         encoded_tiles: encoded_tiles,
         encoding_map: encoding_map,
         pos: {vertical, horizontal}
       ) do
    Enum.flat_map(encoded_tiles, fn {name, orientations} ->
      orientation =
        Enum.find(orientations, fn orientation ->
          vertical_encoding = Keyword.fetch!(orientation, vertical)
          horizontal_encoding = Keyword.fetch!(orientation, horizontal)

          Map.fetch!(encoding_map, vertical_encoding) == MapSet.new([name]) and
            Map.fetch!(encoding_map, horizontal_encoding) == MapSet.new([name])
        end)

      (orientation && [{name, orientation}]) || []
    end)
  end

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

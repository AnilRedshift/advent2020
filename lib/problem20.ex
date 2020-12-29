defmodule Advent2020.Problem20 do
  @tile_length 10

  def run(:part1) do
    tiles = load()
    board_length = square_length(tiles)
    grid = solve(%{tiles: tiles, board_length: board_length})

    [{0, 0}, {board_length - 1, 0}, {0, board_length - 1}, {board_length - 1, board_length - 1}]
    |> Enum.map(&Map.fetch!(grid, &1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(fn a, b -> a * b end)
  end

  def run(:part2) do
    tiles = load()

    image =
      solve(%{tiles: tiles, board_length: square_length(tiles)})
      |> reconstitute(tiles)
      |> remove_border()
      |> combine()

    image_length = square_length(image)

    get_orientations(image, image_length)
    |> Enum.find_value(fn image ->
      case get_sea_monsters(image, image_length) do
        {_image, 0} -> nil
        {image, _} -> image
      end
    end)
    |> Map.values()
    |> Enum.count(&(&1 == true))
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

  defp solve(%{tiles: tiles, board_length: board_length}) do
    encoded_tiles =
      Enum.map(tiles, fn {name, tile} ->
        {name, get_encoded_orientations(tile, @tile_length)}
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

    solve(%{
      remaining_tiles: remaining_tiles,
      grid: grid,
      encoding_map: encoding_map,
      board_length: board_length,
      pos: {1, 0}
    })
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

  defp reconstitute(grid, tiles) do
    Enum.map(grid, fn {pos, {name, encoded_orientation}} ->
      tile =
        Map.fetch!(tiles, name)
        |> get_orientations(@tile_length)
        |> Enum.find(fn tile ->
          encode_tile(tile)
          |> Keyword.equal?(encoded_orientation)
        end)

      {pos, {name, tile}}
    end)
    |> Enum.into(%{})
  end

  defp remove_border(grid) do
    Enum.map(grid, fn {pos, {name, tile}} ->
      new_tile =
        Enum.reduce(0..(@tile_length - 1), tile, fn i, tile ->
          Map.delete(tile, {i, 0})
          |> Map.delete({i, @tile_length - 1})
          |> Map.delete({0, i})
          |> Map.delete({@tile_length - 1, i})
        end)
        |> Enum.map(fn {{x, y}, val} -> {{x - 1, y - 1}, val} end)
        |> Enum.into(%{})

      {pos, {name, new_tile}}
    end)
    |> Enum.into(%{})
  end

  defp combine(grid) do
    board_length = Enum.count(grid) |> :math.sqrt() |> floor()
    # We have removed the border on each side, so remember to use the
    # new tile length
    tile_length = @tile_length - 2

    for y <- 0..(board_length * tile_length - 1) do
      grid_y = Integer.floor_div(y, tile_length)
      inner_y = rem(y, tile_length)

      for x <- 0..(board_length * tile_length - 1) do
        grid_x = Integer.floor_div(x, tile_length)
        inner_x = rem(x, tile_length)

        value =
          Map.fetch!(grid, {grid_x, grid_y})
          |> elem(1)
          |> Map.fetch!({inner_x, inner_y})

        {{x, y}, value}
      end
    end
    |> List.flatten()
    |> Enum.into(%{})
  end

  def load() do
    File.read('input20.txt')
    |> elem(1)
    |> String.split("\n\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse/1)
    |> Enum.into(%{})
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

  defp get_flipped_orientations(tile, tile_length) do
    [
      tile,
      flip(tile, tile_length, :horizontal),
      flip(tile, tile_length, :vertical),
      flip(flip(tile, tile_length, :horizontal), tile_length, :vertical)
    ]
  end

  defp get_rotated_orientations(tile, tile_length) do
    Enum.reduce(1..3, [tile], fn _, tiles ->
      new_tile = rotate_right(hd(tiles), tile_length)
      [new_tile | tiles]
    end)
  end

  defp get_orientations(tile, tile_length) do
    get_rotated_orientations(tile, tile_length)
    |> Enum.flat_map(&get_flipped_orientations(&1, tile_length))
    |> Enum.uniq()
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

  defp get_encoded_orientations(tile, tile_length) do
    get_orientations(tile, tile_length)
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

  def rotate_right(tile, tile_length) do
    # abc
    # def
    # ghi

    # becomes
    # gda
    # heb
    # ifc

    # rotated right again becomes
    # i h g
    # f e d
    # c b a

    Enum.map(tile, fn {{x, y}, val} ->
      new_x = tile_length - 1 - y
      new_y = x
      {{new_x, new_y}, val}
    end)
    |> Enum.into(%{})
  end

  def flip(tile, tile_length, :horizontal) do
    Enum.into(tile, %{}, fn {{x, y}, val} ->
      new_x = tile_length - 1 - x
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

  def flip(tile, tile_length, :vertical) do
    Enum.into(tile, %{}, fn {{x, y}, val} ->
      new_y = tile_length - 1 - y
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

  defp square_length(items) do
    Enum.count(items) |> :math.sqrt() |> floor()
  end

  defp get_sea_monsters(image, image_length) do
    # |                  #
    # |#    ##    ##    ###
    # | #  #  #  #  #  #
    indices = [
      {18, 0},
      {0, 1},
      {5, 1},
      {6, 1},
      {11, 1},
      {12, 1},
      {17, 1},
      {18, 1},
      {19, 1},
      {1, 2},
      {4, 2},
      {7, 2},
      {10, 2},
      {13, 2},
      {16, 2}
    ]

    Enum.reduce(0..(image_length - 1), {image, 0}, fn y, {image, count} ->
      Enum.reduce(0..(image_length - 1), {image, count}, fn x, {image, count} ->
        Enum.all?(indices, fn {offset_x, offset_y} ->
          Map.get(image, {x + offset_x, y + offset_y}) == true
        end)
        |> case do
          true ->
            image =
              Enum.reduce(indices, image, fn {offset_x, offset_y}, image ->
                Map.put(image, {x + offset_x, y + offset_y}, :sea_monster)
              end)

            {image, count + 1}

          false ->
            {image, count}
        end
      end)
    end)
  end
end

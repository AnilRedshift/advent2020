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

defmodule Advent2020.LinkedMap do
  alias Advent2020.LinkedMap
  defstruct data: %{}, head: nil, tail: nil

  def new() do
    %LinkedMap{}
  end

  def new(vals) do
    num_and_next = Enum.chunk_every(vals, 2, 1, [nil])
    num_and_prev = Enum.reverse(vals) |> Enum.chunk_every(2, 1, [nil]) |> Enum.reverse()

    data =
      Enum.zip(num_and_prev, num_and_next)
      |> Enum.map(fn {[num, prev], [num, next]} ->
        {prev, num, next}
      end)
      |> Enum.reduce(%{}, fn
        {prev, num, next}, data ->
          Map.put(data, num, {prev, next})
      end)

    head = Enum.at(vals, 0)
    tail = Enum.reverse(vals) |> Enum.at(0)

    %LinkedMap{data: data, head: head, tail: tail}
  end

  def next(%LinkedMap{} = map, key) do
    Map.fetch!(map.data, key)
    |> elem(1)
  end

  def prev(%LinkedMap{} = map, key) do
    Map.fetch!(map.data, key)
    |> elem(0)
  end

  def delete(%LinkedMap{data: data, head: head}, key)
      when map_size(data) == 1 and key == head do
    %LinkedMap{}
  end

  def delete(%LinkedMap{head: head} = map, key) when key == head do
    next = Map.fetch!(map.data, key) |> elem(1)

    data =
      Map.update!(map.data, next, fn {_prev, next} -> {nil, next} end)
      |> Map.delete(key)

    %LinkedMap{map | data: data, head: next}
  end

  def delete(%LinkedMap{data: data} = map, key) do
    case Map.fetch(data, key) do
      {:ok, {prev, nil}} ->
        data =
          Map.update!(data, prev, fn {prev_prev, ^key} -> {prev_prev, nil} end)
          |> Map.delete(key)

        %LinkedMap{map | data: data, tail: prev}

      {:ok, {prev, next}} ->
        data =
          Map.update!(data, prev, fn {prev_prev, ^key} -> {prev_prev, next} end)
          |> Map.update!(next, fn {^key, next_next} -> {prev, next_next} end)
          |> Map.delete(key)

        %LinkedMap{map | data: data}

      :error ->
        map
    end
  end

  def prepend(%LinkedMap{data: data}, key) when :erlang.is_map_key(key, data) do
    raise ArgumentError, "Cannot prepend an already existing key #{key}"
  end

  def prepend(%LinkedMap{head: nil}, key) do
    LinkedMap.new([key])
  end

  def prepend(%LinkedMap{data: data, head: head}, key) when map_size(data) == 1 do
    LinkedMap.new([key, head])
  end

  def prepend(%LinkedMap{data: data, head: head} = map, key) do
    data =
      Map.update!(data, head, fn {nil, next} -> {key, next} end)
      |> Map.put(key, {nil, head})

    %LinkedMap{map | data: data, head: key}
  end

  def append(%LinkedMap{tail: nil}, key) do
    LinkedMap.new([key])
  end

  def append(%LinkedMap{data: data, head: head}, key) when map_size(data) == 1 do
    LinkedMap.new([key, head])
  end

  def append(%LinkedMap{data: data, tail: tail} = map, key) do
    data =
      Map.update!(data, tail, fn {prev, nil} -> {prev, key} end)
      |> Map.put(key, {tail, nil})

    %LinkedMap{map | data: data, tail: key}
  end

  def insert_after(%LinkedMap{head: nil}, nil, key),
    do: LinkedMap.new([key])

  def insert_after(%LinkedMap{data: data}, _target, key) when :erlang.is_map_key(key, data) do
    raise ArgumentError, "Cannot insert an already existing key #{key}"
  end

  def insert_after(%LinkedMap{data: data, tail: tail} = map, target, key) when target == tail do
    data =
      Map.update!(data, target, fn {prev, nil} -> {prev, key} end)
      |> Map.put(key, {target, nil})

    %LinkedMap{map | data: data, tail: key}
  end

  def insert_after(%LinkedMap{data: data} = map, target, key) do
    next = LinkedMap.next(map, target)

    data =
      Map.update!(data, target, fn {prev, _next} -> {prev, key} end)
      |> Map.update!(next, fn {^target, next} -> {key, next} end)
      |> Map.put(key, {target, next})

    %LinkedMap{map | data: data}
  end

  def head(%LinkedMap{head: head}), do: head
  def tail(%LinkedMap{head: tail}), do: tail

  defimpl Enumerable, for: LinkedMap do
    def count(%LinkedMap{data: data}) do
      {:ok, map_size(data)}
    end

    def member?(%LinkedMap{data: data}, element) do
      {:ok, Map.has_key?(data, element)}
    end

    def reduce(%LinkedMap{head: nil}, {:cont, acc}, _fun) do
      {:done, acc}
    end

    def reduce(%LinkedMap{} = map, {:cont, acc}, fun) do
      new_map = LinkedMap.delete(map, map.head)
      reduce(new_map, fun.(map.head, acc), fun)
    end

    def reduce(%LinkedMap{}, {:halt, acc}, _fun) do
      {:halted, acc}
    end

    def reduce(%LinkedMap{} = map, {:suspend, acc}, fun) do
      {:suspended, acc, &reduce(map, &1, fun)}
    end

    def slice(_) do
      {:error, __MODULE__}
    end
  end
end

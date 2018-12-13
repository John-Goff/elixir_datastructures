defmodule BinaryHeap do
  @moduledoc """
  Purely functional implementation of a binary heap.

  Binary heaps are usually implemented in imperative languages, using mutable arrays. 
  However, purely functional implementations are possible [(Vladimir Kostyukov, 2013)](https://arxiv.org/pdf/1312.4666v1.pdf).
  This is an implementation for Elixir.
  """

  defstruct min: 0, left: :leaf, right: :leaf, size: 0, height: 0

  # Constructor for heaps that preserves the size and height properties
  defp _heap(min, left \\ :leaf, right \\ :leaf), do: %BinaryHeap{
    min: min,
    left: left,
    right: right,
    size: size(left) + size(right) + 1,
    height: max(height(left), height(right)) + 1
  }

  @doc """
  Creates a new heap with the given key.

  ## Examples
  ```
  iex> BinaryHeap.from_key(1)
  %BinaryHeap{key: 1, rank: 1}
  ```
  """
  def from_key(min) when is_integer(min), do: _heap(min)

  @doc """
  Creates a heap from a list.

  ## Examples
  ```
  iex> BinaryHeap.from_list([1, 2, 3])
  %BinaryHeap{key: 1, rank: 2, left: %BinaryHeap{key: 2, rank: 1}, right: %BinaryHeap{key: 3, rank: 1}}
  ```
  """
  def from_list(list) when is_list(list), do: from_list(list, 0)

  defp from_list(list, idx) when idx >= length(list), do: :leaf
  defp from_list(list, idx) do
    min = Enum.at(list, idx)
    bubble_down(min, from_list(list, 2 * idx + 1), from_list(list, 2 * idx + 2))
  end

  @doc """
  Creates a heap from a list.

  ## Examples
  ```
  iex> BinaryHeap.from_list([1, 2, 3])
  %BinaryHeap{key: 1, rank: 2, left: %BinaryHeap{key: 2, rank: 1}, right: %BinaryHeap{key: 3, rank: 1}}
  ```
  """
  def get_min(%BinaryHeap{min: min}), do: min
  def get_min(:leaf), do: {:err, :leaf}

  @doc """
  Returns the size of the heap

  ## Dxamples
  iex> [1, 2, 3] |> BinaryHeap.from_list() |> BinaryHeap.size()
  3
  """
  def size(%BinaryHeap{size: size}), do: size
  def size(:leaf), do: 0

  @doc """
  Converts a heap to a list representation

  ## Examples
  ```
  iex> BinaryHeap.from_key(2) |> BinaryHeap.insert(4) |> BinaryHeap.to_list
  [2, 4]
  ```
  """
  def to_list(:leaf), do: []
  def to_list(%BinaryHeap{} = heap), do: to_list([], heap)

  def to_list(list, :leaf), do: Enum.reverse(list)
  def to_list(list, heap) do
    {:ok, min, new_heap} = delete_min(heap)
    to_list([min | list], new_heap)
  end

  @doc """
  Inserts an item or a list of items into a heap

  ## Examples
  ```
  iex> BinaryHeap.from_key(1) |> BinaryHeap.insert(2)
  %BinaryHeap{key: 1, rank: 1, left: %BinaryHeap{key: 2, rank: 1}}
  iex> BinaryHeap.from_key(1) |> BinaryHeap.insert([2, 3])
  %BinaryHeap{
    key: 1, rank: 1, left: %BinaryHeap{
      key: 2, rank: 1, left: %BinaryHeap{
        key: 3, rank: 1
      }
    }
  }
  ```
  """
  def insert(:leaf, item) when is_integer(item), do: _heap(item)
  def insert(%BinaryHeap{left: left, right: right, min: min}, item) when is_integer(item) do
    cond do
      size(left) < :math.pow(2, height(left)) - 1 ->
        bubble_up(min, insert(left, item), right)
      size(right) < :math.pow(2, height(right)) - 1 ->
        bubble_up(min, left, insert(right, item))
      height(right) < height(left) ->
        bubble_up(min, left, insert(right, item))
      true ->
        bubble_up(min, insert(left, item), right)
    end
  end

  @doc """
  Removes the smallest element.

  ## Examples
  ```
  iex> BinaryHeap.from_list([4, 2, 5]) |> BinaryHeap.delete_min()
  {:ok, 2, %BinaryHeap{key: 4, rank: 1, left: %BinaryHeap{key: 5, rank: 1}}}
  iex> BinaryHeap.delete_min(nil)
  {:err, :empty}
  ```
  """
  def delete_min(:leaf), do: {:err, :leaf}
  def delete_min(%BinaryHeap{min: min, left: left, right: right}) do
    new_heap = case merge(left, right) do
      :leaf -> :leaf
      %BinaryHeap{min: min, left: leftT, right: rightT} ->
        bubble_down(min, leftT, rightT)
    end
    {:ok, min, new_heap}
  end

  defp height(%BinaryHeap{height: height}), do: height
  defp height(:leaf), do: 0

  defp bubble_up(min, %BinaryHeap{min: y, left: leftT, right: rightT}, right) when min > y do
    _heap(y, _heap(min, leftT, rightT), right)
  end
  defp bubble_up(min, left, %BinaryHeap{min: z, left: leftT, right: rightT}) when min > z do
    _heap(z, left, _heap(min, leftT, rightT))
  end
  defp bubble_up(min, left, right), do: _heap(min, left, right)

  defp bubble_down(min, %BinaryHeap{min: left_min} = left, %BinaryHeap{min: right_min} = right) when right_min < left_min and min > right_min do
    _heap(right_min, left, bubble_down(min, right.left, right.right))
  end
  defp bubble_down(min, %BinaryHeap{min: left_min} = left, right) when min > left_min do
    _heap(left_min, bubble_down(min, left.left, left.right), right)
  end
  defp bubble_down(min, left, right), do: _heap(min, left, right)

  defp merge(:leaf, :leaf), do: :leaf
  defp merge(left, right) do
    cond do
      size(left) < :math.pow(2, height(left)) - 1 ->
          float_left(get_min(left), merge(left.left, left.right), right)
      size(right) < :math.pow(2, height(right)) - 1 ->
          float_right(get_min(right), left, merge(right.left, right.right))
      height(right) < height(left) ->
          float_left(get_min(left), merge(left.left, left.right), right)
      true ->
          float_right(get_min(right), left, merge(right.left, right.right))
    end
  end

  defp float_left(min, :leaf, right), do: _heap(min, :leaf, right)
  defp float_left(min, %BinaryHeap{min: left_min, left: leftT, right: rightT}, right) do
    _heap(left_min, _heap(min, leftT, rightT), right)
  end

  defp float_right(min, left, :leaf), do: _heap(min, left, :leaf)
  defp float_right(min, left, %BinaryHeap{min: right_min, left: leftT, right: rightT}) do
    _heap(right_min, left, _heap(min, leftT, rightT))
  end
end
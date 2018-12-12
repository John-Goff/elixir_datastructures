defmodule LeftistHeap do
  @moduledoc """
  Elixir implementation of a leftist tree.
  Leaves are represented by nil. Based on the OCaml implementation available [here](http://typeocaml.com/2015/03/12/heap-leftist-tree/)
  """
  defstruct left: nil, key: 0, right: nil, rank: 0

  @doc """
  Gets the rank of a heap.

  Returns the number representing the distance between the node and the rightmost leaf.
  Will return 0 for a leaf.

  ## Examples

      iex> Heap.rank(%Heap{rank: 2})
      2

      iex> Heap.rank(nil)
      0
  """
  def rank(%LeftistHeap{rank: rank}), do: rank
  def rank(nil), do: 0

  @doc """
  Creates a new heap with the given key.

  ## Examples
  iex> Heap.from_key(1)
  %Heap{key: 1, rank: 1}
  """
  def from_key(key) when is_integer(key), do: %LeftistHeap{key: key, rank: 1}

  def merge(nil, nil), do: nil
  def merge(%LeftistHeap{} = heap, nil), do: heap
  def merge(nil, %LeftistHeap{} = heap), do: heap

  def merge(%LeftistHeap{left: left, right: right, key: key1} = h1, %LeftistHeap{key: key2} = h2) do
    if key1 > key2 do
      merge(h2, h1)
    else
      merged = merge(right, h2)
      rank_left = rank(left)
      rank_right = rank(merged)

      if rank_left >= rank_right do
        %LeftistHeap{h1 | right: merged, rank: rank_right + 1}
      else
        %LeftistHeap{h1 | right: left, left: merged, rank: rank_left + 1}
      end
    end
  end

  def insert(heap, list) when is_list(list), do: list |> from_list() |> merge(heap)
  def insert(heap, key), do: key |> from_key() |> merge(heap)

  def get_min(%LeftistHeap{key: key}), do: key
  def get_min(nil), do: :empty

  def delete_min(%LeftistHeap{right: right, left: left, key: key}),
    do: {:ok, key, merge(right, left)}

  def delete_min(nil), do: {:err, :empty}

  def to_list(%LeftistHeap{} = heap), do: to_list([], heap)
  def to_list(list, nil), do: Enum.reverse(list)

  def to_list(list, %LeftistHeap{} = heap) do
    {:ok, min, new_heap} = delete_min(heap)
    to_list([min | list], new_heap)
  end

  def from_list([head | list]), do: from_list(list, from_key(head))
  def from_list([head | tail], %LeftistHeap{} = heap), do: from_list(tail, insert(heap, head))
  def from_list([], %LeftistHeap{} = heap), do: heap
end

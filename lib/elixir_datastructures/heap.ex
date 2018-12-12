defmodule Heap do
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
  def rank(%Heap{rank: rank}), do: rank
  def rank(nil), do: 0

  def heap_from_key(key) when is_integer(key), do: %Heap{key: key, rank: 1}

  def merge(nil, nil), do: nil
  def merge(%Heap{} = heap, nil), do: heap
  def merge(nil, %Heap{} = heap), do: heap

  def merge(%Heap{left: left, right: right, key: key1} = h1, %Heap{key: key2} = h2) do
    if key1 > key2 do
      _merge(h2, h1)
    else
      merged = _merge(right, h2)
      rank_left = _rank(left)
      rank_right = _rank(merged)

      if rank_left >= rank_right do
        %Heap{h1 | right: merged, rank: rank_right + 1}
      else
        %Heap{h1 | right: left, left: merged, rank: rank_left + 1}
      end
    end
  end

  def insert(heap, list) when is_list(list), do: list |> _from_list() |> _merge(heap)
  def insert(heap, key), do: key |> _heap_from_key() |> _merge(heap)

  def get_min(%Heap{key: key}), do: key
  def get_min(nil), do: :empty

  def delete_min(%Heap{right: right, left: left, key: key}), do: {:ok, key, _merge(right, left)}
  def delete_min(nil), do: {:err, :empty}

  def to_list(%Heap{} = heap), do: _to_list([], heap)
  def to_list(list, nil), do: Enum.reverse(list)

  def to_list(list, %Heap{} = heap) do
    {:ok, min, new_heap} = _delete_min(heap)
    _to_list([min | list], new_heap)
  end

  def from_list([head | list]), do: _from_list(list, _heap_from_key(head))
  def from_list([head | tail], %Heap{} = heap), do: _from_list(tail, _insert(heap, head))
  def from_list([], %Heap{} = heap), do: heap
end

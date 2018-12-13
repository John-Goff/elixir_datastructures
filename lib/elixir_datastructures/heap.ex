defmodule LeftistHeap do
  @moduledoc """
  Elixir implementation of a leftist tree.
  Leaves are represented by nil. Based on the OCaml implementation available [here](http://typeocaml.com/2015/03/12/heap-leftist-tree/)
  """
  defstruct left: nil, key: 0, right: nil, rank: 0

  @doc """
  Creates a new heap with the given key.

  ## Examples
  ```
  iex> LeftistHeap.from_key(1)
  %LeftistHeap{key: 1, rank: 1}
  ```
  """
  def from_key(key) when is_integer(key), do: %LeftistHeap{key: key, rank: 1}

  @doc """
  Creates a heap from a list.

  ## Examples
  ```
  iex> LeftistHeap.from_list([1, 2, 3])
  %LeftistHeap{key: 1, rank: 2, left: %LeftistHeap{key: 2, rank: 1}, right: %LeftistHeap{key: 3, rank: 1}}
  ```
  """
  def from_list([head | list]), do: from_list(list, from_key(head))
  # Recursive implementation of from_list. Pops the first element off a list and adds it to
  # the heap. Continues until no items remain.
  defp from_list([head | tail], %LeftistHeap{} = heap), do: from_list(tail, insert(heap, head))
  # Base case, returns the built up heap
  defp from_list([], %LeftistHeap{} = heap), do: heap

  @doc """
  Return the smallest element in the heap

  ## Examples
  iex> [3, 7, 2, 4, 7, 1] |> LeftistHeap.from_list() |> LeftistHeap.get_min()
  1
  """
  def get_min(%LeftistHeap{key: key}), do: key
  def get_min(nil), do: :empty

  @doc """
  Returns the size of the heap

  ## Dxamples
  iex> [1, 2, 3] |> LeftistHeap.from_list() |> LeftistHeap.size()
  3
  """
  def size(heap), do: heap |> to_list() |> length()

  @doc """
  Converts a heap to a list representation

  ## Examples
  ```
  iex> LeftistHeap.from_key(2) |> LeftistHeap.insert(4) |> LeftistHeap.to_list
  [2, 4]
  ```
  """
  def to_list(%LeftistHeap{} = heap), do: to_list([], heap)

  # Recursive base case, when we hit a leaf we reverse the list we've built by cons
  defp to_list(list, nil), do: Enum.reverse(list)

  # Implements to_list using recursion, pops an element off the heap one by one and
  # cons' it to the the list. Recurses until no more items are left on the heap.
  defp to_list(list, %LeftistHeap{} = heap) do
    {:ok, min, new_heap} = delete_min(heap)
    to_list([min | list], new_heap)
  end

  @doc """
  Inserts an item or a list of items into a heap

  ## Examples
  ```
  iex> LeftistHeap.from_key(1) |> LeftistHeap.insert(2)
  %LeftistHeap{key: 1, rank: 1, left: %LeftistHeap{key: 2, rank: 1}}
  iex> LeftistHeap.from_key(1) |> LeftistHeap.insert([2, 3])
  %LeftistHeap{
    key: 1, rank: 1, left: %LeftistHeap{
      key: 2, rank: 1, left: %LeftistHeap{
        key: 3, rank: 1
      }
    }
  }
  ```
  """
  def insert(heap, list) when is_list(list), do: list |> from_list() |> merge(heap)
  def insert(heap, key), do: key |> from_key() |> merge(heap)

  @doc """
  Removes the smallest element.

  ## Examples
  ```
  iex> LeftistHeap.from_list([4, 2, 5]) |> LeftistHeap.delete_min()
  {:ok, 2, %LeftistHeap{key: 4, rank: 1, left: %LeftistHeap{key: 5, rank: 1}}}
  iex> LeftistHeap.delete_min(nil)
  {:err, :empty}
  ```
  """
  def delete_min(%LeftistHeap{right: right, left: left, key: key}),
    do: {:ok, key, merge(right, left)}

  def delete_min(nil), do: {:err, :empty}

  # Merges two heaps together
  defp merge(nil, nil), do: nil
  defp merge(%LeftistHeap{} = heap, nil), do: heap
  defp merge(nil, %LeftistHeap{} = heap), do: heap

  defp merge(%LeftistHeap{left: left, right: right, key: key1} = h1, %LeftistHeap{key: key2} = h2) do
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

  # Returns the number representing the distance between the node and the rightmost leaf.
  # Will return 0 for a leaf.
  defp rank(%LeftistHeap{rank: rank}), do: rank
  defp rank(nil), do: 0
end

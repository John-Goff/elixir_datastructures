defmodule Heap do
  use GenServer
  defstruct left: nil, key: 0, right: nil, rank: 0

  # Client 
  def start_link, do: GenServer.start_link(__MODULE__, %Heap{}, name: ElixirHeap)
  def start_link(list) when is_list(list),
    do: GenServer.start_link(__MODULE__, _from_list(list), name: ElixirHeap)
  def start_link(item), do: GenServer.start_link(__MODULE__, _heap_from_key(item), name: ElixirHeap)

  def min(), do: GenServer.call(ElixirHeap, :min)

  def size(), do: GenServer.call(ElixirHeap, :size)

  def to_list(), do: GenServer.call(ElixirHeap, :to_list)

  def insert(item), do: GenServer.cast(ElixirHeap, {:insert, item})

  def remove() do
    minimum = min()
    case GenServer.cast(ElixirHeap, :delete_min) do
      :ok -> {:ok, minimum}
      other -> {other}
    end
  end

  # Callbacks
  @impl true
  def init(%Heap{}), do: {:ok, %Heap{}}

  @impl true
  def handle_call(:size, _from, heap), do: {:reply, length(_to_list(heap)), heap}

  @impl true
  def handle_call(:min, _from, heap), do: {:reply, _get_min(heap), heap}

  @impl true
  def handle_call(:to_list, _from, heap), do: {:reply, _to_list(heap), heap}

  @impl true
  def handle_cast({:insert, item}, heap), do: {:noreply, _insert(heap, item)}

  @impl true
  def handle_cast(:delete_min, heap) do
    case _delete_min(heap) do
      {:ok, _removed, new_heap} -> {:noreply, new_heap}
      _ -> {:noreply, heap}
    end
  end

  # Implementation of leftist heap data structure, loosely based on: http://typeocaml.com/2015/03/12/heap-leftist-tree/
  def _rank(%Heap{rank: rank}), do: rank
  def _rank(nil), do: 0

  def _heap_from_key(key) when is_integer(key), do: %Heap{key: key, rank: 1}

  def _merge(nil, nil), do: nil
  def _merge(%Heap{} = heap, nil), do: heap
  def _merge(nil, %Heap{} = heap), do: heap
  def _merge(%Heap{left: left, right: right, key: key1} = h1, %Heap{key: key2} = h2) do
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

  def _insert(heap, list) when is_list(list), do: list |> _from_list() |> _merge(heap)
  def _insert(heap, key), do: key |> _heap_from_key() |> _merge(heap)

  def _get_min(%Heap{key: key}), do: key
  def _get_min(nil), do: :empty

  def _delete_min(%Heap{right: right, left: left, key: key}), do: {:ok, key, _merge(right, left)}
  def _delete_min(nil), do: {:err, :empty}

  def _to_list(%Heap{} = heap), do: _to_list([], heap)
  def _to_list(list, nil), do: Enum.reverse(list)
  def _to_list(list, %Heap{} = heap) do
    {:ok, min, new_heap} = _delete_min(heap)
    _to_list([min | list], new_heap)
  end

  def _from_list([head | list]), do: _from_list(list, _heap_from_key(head))
  def _from_list([head | tail], %Heap{} = heap), do: _from_list(tail, _insert(heap, head))
  def _from_list([], %Heap{} = heap), do: heap
end

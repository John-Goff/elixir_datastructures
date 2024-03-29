defmodule HeapServerThree do
  use GenServer

  @vsn 1

  ## Client 

  def start_link(heap \\ nil),
    do: GenServer.start_link(__MODULE__, heap, name: HSThree)

  def min(), do: GenServer.call(HSThree, :min)

  def size(), do: GenServer.call(HSThree, :size)

  def to_list(), do: GenServer.call(HSThree, :to_list)

  def insert(item), do: GenServer.cast(HSThree, {:insert, item})

  def delete_min() do
    minimum = min()

    case GenServer.cast(HSThree, :delete_min) do
      :ok -> {:ok, minimum}
      other -> {other}
    end
  end

  ## Callbacks

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:min, _from, heap), do: {:reply, Heap.get_min(heap), heap}

  @impl true
  def handle_call(:size, _from, heap), do: {:reply, Heap.size(heap), heap}

  @impl true
  def handle_call(:to_list, _from, heap), do: {:reply, Heap.to_list(heap), heap}

  @impl true
  def handle_cast({:insert, item}, heap), do: {:noreply, Heap.insert(heap, item)}

  @impl true
  def handle_cast(:delete_min, heap) do
    case Heap.delete_min(heap) do
      {:ok, _removed, new_heap} -> {:noreply, new_heap}
      _ -> {:noreply, heap}
    end
  end
end

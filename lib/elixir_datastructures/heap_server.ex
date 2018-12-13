defmodule HeapServer do
  use GenServer
  alias LeftistHeap, as: Heap

  # Client 
  def start_link,
    do: GenServer.start_link(__MODULE__, %Heap{}, name: ElixirHeap)

  def start_link(list) when is_list(list),
    do: GenServer.start_link(__MODULE__, Heap.from_list(list), name: ElixirHeap)

  def start_link(item),
    do: GenServer.start_link(__MODULE__, Heap.from_key(item), name: ElixirHeap)

  def min(), do: GenServer.call(ElixirHeap, :min)

  def size(), do: GenServer.call(ElixirHeap, :size)

  def to_list(), do: GenServer.call(ElixirHeap, :to_list)

  def insert(item), do: GenServer.cast(ElixirHeap, {:insert, item})

  def delete_min() do
    minimum = min()

    case GenServer.cast(ElixirHeap, :delete_min) do
      :ok -> {:ok, minimum}
      other -> {other}
    end
  end

  # Callbacks
  # @impl true
  # def code_change(_vsn, state, extra) do
  #   new_state = state
  #   |> BinaryHeap.to_list()
  #   |> LeftistHeap.from_list()
  #   {:ok, new_state}
  # end

  # @impl true
  # def code_change(_vsn, state, extra) do
  #   new_state = state
  #   |> LeftistHeap.to_list()
  #   |> BinaryHeap.from_list()
  #   {:ok, new_state}
  # end

  @impl true
  def init(%Heap{}), do: {:ok, %Heap{}}

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

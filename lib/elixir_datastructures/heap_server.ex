defmodule HeapServer do
  use GenServer
  alias LeftistHeap, as: LHeap

  # Client
  def start_link,
    do: GenServer.start_link(__MODULE__, %LHeap{}, name: HSOne)

  def start_link(list) when is_list(list),
    do: GenServer.start_link(__MODULE__, LHeap.from_list(list), name: HSOne)

  def start_link(item),
    do: GenServer.start_link(__MODULE__, LHeap.from_key(item), name: HSOne)

  def min(), do: GenServer.call(HSOne, :min)

  def size(), do: GenServer.call(HSOne, :size)

  def to_list(), do: GenServer.call(HSOne, :to_list)

  def insert(item), do: GenServer.cast(HSOne, {:insert, item})

  def delete_min() do
    minimum = min()

    case GenServer.cast(HSOne, :delete_min) do
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
  def init(%LHeap{}), do: {:ok, %LHeap{}}

  @impl true
  def handle_call(:min, _from, heap), do: {:reply, LHeap.get_min(heap), heap}

  @impl true
  def handle_call(:size, _from, heap), do: {:reply, LHeap.size(heap), heap}

  @impl true
  def handle_call(:to_list, _from, heap), do: {:reply, LHeap.to_list(heap), heap}

  @impl true
  def handle_cast({:insert, item}, heap), do: {:noreply, LHeap.insert(heap, item)}

  @impl true
  def handle_cast(:delete_min, heap) do
    case LHeap.delete_min(heap) do
      {:ok, _removed, new_heap} -> {:noreply, new_heap}
      _ -> {:noreply, heap}
    end
  end
end

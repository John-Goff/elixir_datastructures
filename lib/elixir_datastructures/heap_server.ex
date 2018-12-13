defmodule HeapServer do
  use GenServer

  ## Client 

  def start_link(module \\ LeftistHeap, heap \\ nil),
    do: GenServer.start_link(__MODULE__, {module, heap}, name: ElixirHeap)

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

  ## Callbacks

  # @impl true
  # def code_change(_vsn, {_module, heap}, extra) do
  #   new_heap = heap
  #   |> LeftistHeap.to_list()
  #   |> BinaryHeap.from_list()
  #   {:ok, {BinaryHeap, new_heap}}
  # end

  # @impl true
  # def code_change(_vsn, {_module, heap}, extra) do
  #   new_heap = heap
  #   |> BinaryHeap.to_list()
  #   |> LeftistHeap.from_list()
  #   {:ok, {LeftistHeap, new_heap}}
  # end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:min, _from, {module, heap}), do: {:reply, module.get_min(heap), {module, heap}}

  @impl true
  def handle_call(:size, _from, {module, heap}), do: {:reply, module.size(heap), {module, heap}}

  @impl true
  def handle_call(:to_list, _from, {module, heap}), do: {:reply, module.to_list(heap), {module, heap}}

  @impl true
  def handle_cast({:insert, item}, {module, heap}), do: {:noreply, {module, module.insert(heap, item)}}

  @impl true
  def handle_cast(:delete_min, {module, heap} = state) do
    case module.delete_min(heap) do
      {:ok, _removed, new_heap} -> {:noreply, {module, new_heap}}
      _ -> {:noreply, state}
    end
  end
end

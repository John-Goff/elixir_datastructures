defmodule HeapServerTwo do
  use GenServer

  @vsn 1

  ## Client 

  def start_link(module \\ LeftistHeap, heap \\ nil),
    do: GenServer.start_link(__MODULE__, {module, heap}, name: HSTwo)

  def min(), do: GenServer.call(HSTwo, :min)

  def size(), do: GenServer.call(HSTwo, :size)

  def to_list(), do: GenServer.call(HSTwo, :to_list)

  def insert(item), do: GenServer.cast(HSTwo, {:insert, item})

  def delete_min() do
    minimum = min()

    case GenServer.cast(HSTwo, :delete_min) do
      :ok -> {:ok, minimum}
      other -> {other}
    end
  end

  ## Callbacks

  @impl true
  def code_change(vsn, {_module, heap}, extra) do
    {old_module, new_module} = case vsn do
      1 -> {LeftistHeap, BinaryHeap}
      {:down, 2} -> {BinaryHeap, LeftistHeap}
    end
    new_heap = heap
    |> old_module.to_list()
    |> new_module.from_list()
    {:ok, {new_module, new_heap}}
  end

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

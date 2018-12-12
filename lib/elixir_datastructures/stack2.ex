defmodule StackTwo do
  use GenServer

  # Client Functions
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: HiredHippoStack)
  end

  def push(item), do: GenServer.cast(HiredHippoStack, {:push, item})

  def pop(), do: GenServer.call(HiredHippoStack, :pop)

  # Callbacks
  @impl true
  def init(stack), do: {:ok, stack}

  @impl true
  def handle_call(:pop, _from, [head | tail]), do: {:reply, head, tail}

  @impl true
  def handle_cast({:push, item}, state), do: {:noreply, [item | state]}
end

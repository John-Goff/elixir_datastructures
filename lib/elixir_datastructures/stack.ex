defmodule Stack do
  use GenServer

  @impl true
  def init(stack), do: {:ok, stack}

  @impl true
  def handle_call(:pop, _from, [head | tail]), do: {:reply, head, tail}

  @impl true
  def handle_cast({:push, item}, state), do: {:noreply, [item | state]}
end

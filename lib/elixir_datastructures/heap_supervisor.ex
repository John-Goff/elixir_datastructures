defmodule HeapSupervisor do
  use Supervisor

  @impl true
  def start_link(opts), do: Supervisor.start_link(__MODULE__, :ok, opts)

  @impl true
  def init(:ok), do: Supervisor.init(children(), strategy: :one_for_one)

  defp children(), do: [
    %{ id: HeapServer, start: {HeapServer, :start_link, []} }
  ]
end

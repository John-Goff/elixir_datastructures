defmodule ElixirDatastructures do
  @moduledoc """
  Some datastructure implementations in Elixir
  """
  use Application

  def start(_type, _args), do: HeapSupervisor.start_link(name: Heap.Supervisor)
end

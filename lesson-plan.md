stack.ex examine code
* What is a GenServer?
  - Set of behaviours
  - implements a server in a client-server model
  - defined in OTP
  - just functions(TM)
* Elixir is a compiled language
* pattern matching a list
* linked lists
iex> import_file "stack.ex"
iex> {:ok, pid} = GenServer.start_link(Stack, [])
iex> pid |> GenServer.cast({:push, :hippo})
iex> pid |> GenServer.cast({:push, :hired})
iex> pid |> GenServer.call()
iex> pid |> GenServer.call()
iex> pid |> GenServer.call()

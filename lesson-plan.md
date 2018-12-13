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
iex> pid |> GenServer.cast({:push, :world})
iex> pid |> GenServer.cast({:push, :hello})
iex> pid |> GenServer.call(:pop)
iex> pid |> GenServer.call(:pop)
iex> pid |> GenServer.call(:pop)
* It crashed.
  - doesn't respond to any further messages
* That's ok, we can restart it.
* But what if we don't want to restart it every time?
* Use a Supervisor
* need client functions for that
stack2.ex examine code
* same as last time, but we have an api instead of calling GenServer manually
* we can use this api, so can Supervisor
iex> import_file "stack2.ex"
iex> StackTwo.start_link([:world])
iex> StackTwo.push(:hello)
iex> StackTwo.pop()
iex> StackTwo.pop()
iex> StackTwo.pop()
* Same crash as before, just nicer to read and type
iex> {:ok, pid} = Supervisor.start_link([{StackTwo, [:world]}, strategy: :one_for_one)
iex> StackTwo.push(:hello)
iex> StackTwo.pop()
iex> StackTwo.pop()
iex> StackTwo.pop()
* Same crash, but this time, if we try and continue to use it, it works!
iex> StackTwo.push(:world)
iex> StackTwo.push(:hello)
iex> StackTwo.pop()
iex> StackTwo.pop()
heap.ex examine code
* Ok, time for a more serious data structre

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
iex> {:ok, pid} = Supervisor.start_link([{StackTwo, [:world]}], strategy: :one_for_one)
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
* This file implements a leftist heap in elixir.
* Only focus on the public api, functions with @doc comments
* Implementation isn't important
heap_server.ex examine code
* Server that implements the leftist heap
* Some functions for working with a heap, delegates everything to heap module
$ iex -S mix
iex> HeapServer.start_link
iex> HeapServer.insert(5)
iex> HeapServer.insert(8)
iex> HeapServer.insert(3)
iex> HeapServer.insert(4)
iex> HeapServer.to_list
iex> HeapServer.delete_min
iex> HeapServer.to_list
* We can use :sys to debug
* :sys.get_state allows us to inspect a GenServer's state
iex> :sys.get_state(ElixirHeap)
heap2.ex examine code
* Implementation of a binary heap in elixir
* differences aren't important, only need to know that same rules are in place, and same api
* We can switch our running GenServer to use this new implementation
heap_server.ex, replace alias LeftistHeap with alias BinaryHeap, and uncomment second code_change block
iex> :sys.suspend(ElixirHeap)
iex> r HeapServer
iex> :sys.change_code(ElixirHeap, HeapServer, nil, [])
iex> :sys.resume(ElixirHeap)
iex> :sys.get_state(ElixirHeap)
* Oh no, we found a bug with the implementation
* replace the alias, comment the second block and uncomment the first
iex> :sys.suspend(ElixirHeap)
iex> r HeapServer
iex> :sys.change_code(ElixirHeap, HeapServer, nil, [])
iex> :sys.resume(ElixirHeap)
iex> :sys.get_state(ElixirHeap)

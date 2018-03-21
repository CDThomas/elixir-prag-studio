defmodule Servy.FourOhFourCounter.GenericServer do
  # Client
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})
    receive do {:response, response} -> response end
  end

  def cast(pid, message),  do: send(pid, {:cast, message})

  # Server
  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)
      message ->
        new_state = callback_module.handle_info(message, state)
        listen_loop(new_state, callback_module)
    end
  end
end

defmodule Servy.FourOhFourCounter do
  use GenServer

  @name __MODULE__

  # Client
  def start, do: GenServer.start(__MODULE__, %{}, name: @name)

  def init(state), do: {:ok, state}

  def bump_count(path) do
    GenServer.cast(@name, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(@name, {:get_count, path})
  end

  def get_counts do
    GenServer.call(@name, :get_counts)
  end

  # Server
  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end
  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:bump_count, path}, state) do
    {:noreply, Map.update(state, path, 1, &(&1 + 1))}
  end

  def handle_info(message, state) do
    IO.puts("Unexpected message: #{inspect(message)}")
    {:noreply, state}
  end
end

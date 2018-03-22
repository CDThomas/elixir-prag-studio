defmodule Servy.PledgeServer do
  @name __MODULE__

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client interface
  def start_link(_args) do
    IO.puts("Starting the pledge server...")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged() do
    GenServer.call(@name, :total_pledged)
  end

  def clear() do
    GenServer.cast(@name, :clear)
  end

  def set_cache_size(cache_size) do
    GenServer.cast(@name, {:set_cache_size, cache_size})
  end

  # Server callbacks
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    {:ok, %{state | pledges: pledges}}
  end

  def handle_call(:total_pledged, _from, state) do
    total =
      state.pledges
        |> Enum.map(&elem(&1, 1))
        |> Enum.sum()

    {:reply, total, state}
  end
  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end
  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]

    {:reply, id, %{state | pledges: cached_pledges }}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end
  def handle_cast({:set_cache_size, cache_size}, state) do
    {:noreply, %{state | cache_size: cache_size}}
  end

  def handle_info(message, state) do
   IO.puts("Recieved unhandled message: #{inspect message}")
   {:noreply, state}
  end

  def send_pledge_to_service(_name, _amount) do
    # Code would go here to send to external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  def fetch_recent_pledges_from_service do
    [{"joseph", 25}, {"susan", 45}]
  end
end

# alias Servy.PledgeServer

# {:ok, pid} = PledgeServer.start()

# send(pid, {:merp, "hi"})

# PledgeServer.create_pledge("larry", 10) |> IO.inspect
# PledgeServer.create_pledge("moe", 20) |> IO.inspect
# PledgeServer.create_pledge("curly", 30) |> IO.inspect
# PledgeServer.create_pledge("daisy", 40) |> IO.inspect
# PledgeServer.create_pledge("grace", 50) |> IO.inspect

# :sys.get_state(pid) |> IO.inspect

# PledgeServer.recent_pledges() |> IO.inspect

# PledgeServer.total_pledged() |> IO.inspect

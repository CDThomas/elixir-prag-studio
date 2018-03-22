defmodule Servy.SensorServer do

  @name :sensor_server

  use GenServer

  defmodule State do
    defstruct sensor_data: %{}, refresh_interval: nil, timer_ref: nil
  end

  # Client Interface

  def start_link(opts) do
    refresh_interval = Keyword.get(opts, :refresh_interval, :timer.minutes(5))
    IO.puts("Starting the sensor server...")
    GenServer.start_link(__MODULE__, %State{refresh_interval: refresh_interval}, name: @name)
  end

  def get_sensor_data do
    GenServer.call @name, :get_sensor_data
  end

  def set_refresh_interval(interval_in_ms) do
    GenServer.cast @name, {:set_refresh_interval, interval_in_ms}
  end

  # Server Callbacks

  def init(state) do
    sensor_data = run_tasks_to_get_sensor_data()
    timer_ref = schedule_refresh(state.refresh_interval)
    {:ok, %{state | sensor_data: sensor_data, timer_ref: timer_ref}}
  end

  def handle_info(:refresh, state) do
    IO.puts("Refreshing cache...")
    sensor_data = run_tasks_to_get_sensor_data()
    timer_ref = schedule_refresh(state.refresh_interval)
    {:noreply, %{state | sensor_data: sensor_data, timer_ref: timer_ref}}
  end

  defp schedule_refresh(refresh_interval) do
    IO.puts "Scheduling again for #{refresh_interval}"
    Process.send_after(self(), :refresh, refresh_interval)
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_cast({:set_refresh_interval, interval_in_ms}, state) do
    Process.cancel_timer(state.timer_ref)
    timer_ref = schedule_refresh(interval_in_ms)
    {:noreply, %{state | refresh_interval: interval_in_ms, timer_ref: timer_ref}}
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data..."

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end

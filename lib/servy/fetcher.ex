defmodule Servy.Fetcher do
  @moduledoc """
  This is basically what Task does
  """

  def async(func) do
    parent = self()
    spawn(fn -> send(parent, {self(), :result, func.()}) end)
  end

  def get_result(pid) do
    receive do
      {^pid, :result, value} -> value
    after 2_000 ->
      {:error, :time_out}
    end
  end
end

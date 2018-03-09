defmodule Servy.Timer do
  def remind(message, seconds_to_wait) do
    spawn(fn ->
      :timer.sleep(seconds_to_wait * 1_000)
      IO.puts(message)
    end)
  end
end

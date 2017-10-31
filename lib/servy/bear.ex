defmodule Servy.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def grizzly?(bear), do: bear.type == "Grizzly"

  def order_asc_by_name(bear_one, bear_two) do
    bear_one.name <= bear_two.name
  end
end

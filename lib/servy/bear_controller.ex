defmodule Servy.BearController do
  alias Servy.{View, Bear, Wildthings}

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    View.render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    View.render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Name: #{name}, Type: #{type}"}
  end

  def delete(conv, _params) do
    %{conv | status: 403, resp_body: ""}
  end
end
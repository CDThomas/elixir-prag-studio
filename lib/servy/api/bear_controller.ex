defmodule Servy.Api.BearController do
  alias Servy.{Conv, Wildthings}

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Poison.encode!

    conv = Conv.put_resp_header(conv, "Content-Type", "application/json")
    %{conv | status: 200, resp_body: bears}
  end

  def create(conv, %{"type" => type, "name" => name}) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end
end

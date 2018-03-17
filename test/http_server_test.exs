defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "Can successfully respond" do
    spawn(HttpServer, :start, [4000])

    ["/api/bears", "/bears", "/wildthings"]
    |> Enum.map(&Task.async(HTTPoison, :get, ["http://localhost:4000" <> &1]))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)
  end

  def assert_successful_response({:ok, response}) do
    assert response.status_code == 200
  end
end

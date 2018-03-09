defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "Can successfully respond" do
    spawn(HttpServer, :start, [4000])

    expected_response = [
      %{"type" => "Brown", "name" =>  "Teddy", "id" =>  1, "hibernating" =>  true},
      %{"type" => "Black","name" => "Smokey","id" => 2,"hibernating" => false},
      %{"type" => "Brown","name" => "Paddington","id" => 3,"hibernating" => false},
      %{"type" => "Grizzly","name" => "Scarface","id" => 4,"hibernating" => true},
      %{"type" => "Polar","name" => "Snow","id" => 5,"hibernating" => false},
      %{"type" => "Grizzly","name" => "Brutus","id" => 6,"hibernating" => false},
      %{"type" => "Black","name" => "Rosie","id" => 7,"hibernating" => true},
      %{"type" => "Panda","name" => "Roscoe","id" => 8,"hibernating" => false},
      %{"type" => "Polar","name" => "Iceman","id" => 9,"hibernating" => true},
      %{"type" => "Grizzly","name" => "Kenai","id" => 10,"hibernating" => false}
    ]
    max_concurrent_requests = 5
    caller = self()

    for _ <- 1..max_concurrent_requests do
      spawn(fn ->
        {:ok, response} = HTTPoison.get("http://localhost:4000/api/bears")
        send(caller, {:ok, response})
      end)
    end

    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body |> Poison.decode! == expected_response
      end
    end
  end
end

defmodule Servy.ImageApi do
  def query(id) do
    id
      |> api_url()
      |> HTTPoison.get()
      |> handle_response()
  end

  def api_url(id) do
    "https://api.myjson.com/bins/#{URI.encode(id)}"
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    image_url =
      body
        |> Poison.decode!
        |> get_in(["image", "image_url"])

    {:ok, image_url}
  end
  def handle_response({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    message =
      body
        |> Poison.decode!
        |> get_in(["message"])

    {:error, message}
  end
  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end

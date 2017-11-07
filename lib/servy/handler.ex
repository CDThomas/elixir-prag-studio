defmodule Servy.Handler do
  @moduledoc """
  Elixir and functional programming:
  * Transforming data with functions
  * Ex: the request (input) to our web server will go through a series of transformations
    and output a response

  Ruby and OOP:
  * Objects
  * Call method on objects to change state

  HTTP Request:
  * Request line, headers, and optional body

  HTTP Response:
  * Content-Length: header for the size (in bytes) of the response body

  `conv` is short for conversation

  term: a value of any data type (string, atom, list, map, etc.)

  TODO:
  * go back over recursion exercises (and maybe vid, too)
  """

  import Servy.Plugins, only: [
    rewrite_path: 1,
    log: 1,
    track: 1,
    put_content_length: 1,
  ]
  import Servy.Parser, only: [parse: 1]
  alias Servy.{Conv, BearController}
  alias Servy.Api.BearController, as: ApiBearController

  @pages_path Path.expand("../../pages", __DIR__)

  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> put_content_length()
    |> format_response()
  end

  @doc """
  Transform request response into a new map with a response body
  """
  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end
  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end
  def route(%Conv{method: "POST", path: "/bears", params: params} = conv) do
    BearController.create(conv, params)
  end
  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end
  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end
  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end
  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end
  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    ApiBearController.index(conv)
  end
  def route(%Conv{method: "POST", path: "/api/bears", params: params} = conv) do
    ApiBearController.create(conv, params)
  end
  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here"}
  end

  def handle_file({:ok, content}, %Conv{} = conv) do
    %{conv | status: 200, resp_body: content}
  end
  def handle_file({:error, :enoent}, %Conv{} = conv) do
    %{conv | status: 404, resp_body: ""}
  end
  def handle_file({:error, reason}, %Conv{} = conv) do
    %{conv | status: 500, resp_body: "Error: #{reason}"}
  end

  @doc """
  Format the response map as valid HTTP response string
  """
  def format_response(%Conv{resp_headers: resp_headers, resp_body: resp_body} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_resp_headers(resp_headers)}
    \r
    #{resp_body}
    """
  end

  defp format_resp_headers(resp_headers) do
    resp_headers
      |> Enum.map(fn {key, val} -> "#{key}: #{val}\r" end)
      |> Enum.sort() # How are headers actually sorted? Does it matter? This matches the tests
      |> Enum.reverse()
      |> Enum.join("\n")
  end
end


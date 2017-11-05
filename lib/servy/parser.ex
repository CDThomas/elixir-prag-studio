defmodule Servy.Parser do
  alias Servy.Conv

  @doc """
  Parse the request string into key/value pairs
  """
  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _version] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2` into a
  map with corresponding keys and values.

  Unsupported formats will return an empty map.

  ## Examples
      iex> params_string = "name=Judge&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Judge", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/form-data", params_string)
      %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end
  def parse_params(_content_type, _params_string), do: %{}

  # Recursive version of parse_headers
  # def parse_headers(header_lines, headers \\ %{})
  # def parse_headers([head | tail], headers) do
  #   [key, val] = String.split(head, ": ")
  #   parse_headers(tail, Map.put(headers, key, val))
  # end
  # def parse_headers([], headers), do: headers

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn(header_line, headers) ->
      [key, val] = String.split(header_line, ": ")
      Map.put(headers, key, val)
    end)
  end
end

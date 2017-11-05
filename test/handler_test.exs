defmodule Handler.HandlerTest do
  use ExUnit.Case

  alias Servy.Handler

  test "GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """
  end

  test "GET /bears" do
    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 355\r
    \r
    <h1>All the bears</h1>

    <ul>
      <li>Brutus - Grizzly</li>
      <li>Iceman - Polar</li>
      <li>Kenai - Grizzly</li>
      <li>Paddington - Brown</li>
      <li>Roscoe - Panda</li>
      <li>Rosie - Black</li>
      <li>Scarface - Grizzly</li>
      <li>Smokey - Black</li>
      <li>Snow - Polar</li>
      <li>Teddy - Brown</li>
    </ul>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /bigfoot" do
    request = """
    GET /bigfoot HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    assert response == """
    HTTP/1.1 404 Not Found\r
    Content-Type: text/html\r
    Content-Length: 16\r
    \r
    No /bigfoot here
    """
  end

  test "GET /bears/1" do
    request = """
    GET /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 48\r
    \r
    <h1>Show bear</h1>
    <p>
    Teddyishibernating
    </p>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """
  end

  test "GET /about" do
    request = """
    GET /about HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 100\r
    \r
    <h1>Clark's Wildthings Refuge</h1>

    <blockquote>
    When we contemplate the whole globe...
    </blockquote>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "POST /bears" do
    request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21\r
    \r
    name=Baloo&type=Brown
    """

    response = Handler.handle(request)

    assert response == """
    HTTP/1.1 201 Created\r
    Content-Type: text/html\r
    Content-Length: 24\r
    \r
    Name: Baloo, Type: Brown
    """
  end

  test "DELETE  /bears/1" do
    request = """
    DELETE /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    assert response == """
    HTTP/1.1 403 Forbidden\r
    Content-Type: text/html\r
    Content-Length: 0\r
    \r

    """
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
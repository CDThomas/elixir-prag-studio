defmodule Servy.Plugins do
  require Logger
  alias Servy.Conv

  @doc "Logs 404 requests"
  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn "Warning #{path} not found"
    conv
  end
  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end
  def rewrite_path(%Conv{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/#{id}"}
  end
  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    conv |> inspect() |> Logger.info()
    conv
  end
end


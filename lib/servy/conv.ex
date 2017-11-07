defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            params: %{},
            headers: %{},
            resp_body: "",
            status: nil,
            resp_headers: %{"Content-Type" => "text/html"}

  def put_resp_header(conv, header, value) do
    resp_headers = Map.put(conv.resp_headers, header, value)
    %{conv | resp_headers: resp_headers}
  end

  def full_status(%__MODULE__{status: status}) do
    "#{status} #{status_reason(status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

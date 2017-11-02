defmodule Servy.View do
   @templates_path Path.expand("../../templates", __DIR__)

  # TODO: EEx.function_from_file for precompiled files
  def render(conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{conv | status: 200, resp_body: content}
  end
end

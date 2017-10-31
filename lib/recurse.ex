defmodule Recurse do
  @moduledoc """
  Just practicing recursion. This isn't used by Servy.
  """

  def sum(number, acc \\ 0)
  def sum([], acc), do: acc
  def sum([number | rest], acc) do
    sum(rest, number + acc)
  end

  def triple([]), do: []
  def triple([head | tail]) do
    [head * 3 | triple(tail)]
  end

  def map([], _func), do: []
  def map([head | tail], func) do
    [func.(head) | map(tail, func)]
  end
end

defmodule NestedMap.Flattener do
  @moduledoc """
  Flattens a nested map by using an iterative approach, therefore even
  extremely deeply nested maps can be flattened without stack overflow
  """

  @doc false
  def flatten(input, prefixes, result)
  def flatten([{k, v}|rest], prefixes, result) when is_map(v), do: _pushm(rest, k, v, prefixes, result)
  def flatten([pair|rest], prefixes, result) when is_tuple(pair), do: _pusht(rest, pair, prefixes, result)
  def flatten([[]|rest], prefixes, result), do: _closel(rest, prefixes, result)
  def flatten([lst|rest], prefixes, result) when is_list(lst), do: _openl(rest, lst, prefixes, result)
  def flatten([], _, result), do: _reverse_result_and_keys(result, [])

  defp _closel(rest, [_|prefixes], result), do: flatten(rest, prefixes, result)

  defp _openl(rest, [h|t], prefixes, result), do: flatten([h, t | rest], prefixes, result)

  defp _pushm(rest, k, v, prefixes, result) do
    new_input = [v |> Enum.into([]) | rest]
    flatten(new_input, [k|prefixes], result)
  end

  defp _pusht(rest, {k, v}, prefixes, result), do: flatten(rest, prefixes, [{[k|prefixes], v}|result])

  defp _reverse_result_and_keys(reversed, result)
  defp _reverse_result_and_keys([], result), do: result
  defp _reverse_result_and_keys([{keys, value}|rest], result) do
    _reverse_result_and_keys(rest, [{Enum.reverse(keys), value}|result])
  end

end

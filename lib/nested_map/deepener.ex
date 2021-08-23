defmodule NestedMap.Deepener do
  use NestedMap.Types

  # Notation:
  #   last entry's key, is when inserting {[:a, :b, :c], value} (which is a flattened representation of
  #   %{a: %{b: %{c: value}}}) into %{a: %{ b: %{d: 1}} :b would be the lek and [:a, :b] would be the sequence
  #   leading up to the `lek` which will be called `insert_prefix`
  @moduledoc false

  def deepen(flattened),
    do:
      flattened
      |> Enum.reduce(%{}, &_add_to_map/2)

  defp _add_to_map(flattened_map_entry, result), do: _descent([], flattened_map_entry, [result])

  defp _ascent(keys, result_stack)
  defp _ascent([key|keys], [fst, snd|rest]), do: _ascent(keys, [Map.put(snd, key, fst)|rest])
  defp _ascent([], [result]), do: result


  defp _descent(keys, flattened_map_entry, result_stack)
  defp _descent(keys, {[_key], _value}=flattened_map_entry, result) do
    _ascent(keys, _merge_onto_head(flattened_map_entry, result))
  end
  defp _descent(keys, {[key|keys1], value}=flattened_map_entry, [head|_tail]=result) do
    case _get_map_entry(head, key) do
      :error -> _ascent(keys,_merge_onto_head(flattened_map_entry, result)) 
      {:ok, entry} -> _descent([key|keys], {keys1, value}, [entry|result])
    end
  end

  defp _get_map_entry(map, key) do
    case Map.fetch(map, key) do
      :error -> :error
      {:ok, value} -> if is_map(value), do: {:ok, value}, else: :error
    end
  end

  defp _make_map_entry({keys, value}) do
    keys
    |> Enum.reverse()
    |> Enum.reduce(value, fn k, result -> %{k => result} end)
  end

  defp _merge_onto_head(flattened_map_entry, [head|tail]) do
    [Map.merge(head, _make_map_entry(flattened_map_entry)) | tail]
  end
end

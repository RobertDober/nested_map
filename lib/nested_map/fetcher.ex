defmodule NestedMap.Fetcher do
  @moduledoc """
  Implements deep access to nested values
  """

  @doc false
  def fetch(map, keys), do: Enum.reduce_while(keys, {:ok, map}, &_accessor/2)

  defp _accessor(key, map)
  defp _accessor(key, {:ok, map}) when is_map(map) do
    case Map.fetch(map, key) do
      {:ok, ele} -> {:cont, {:ok, ele}}
      _ -> {:halt, :error}
    end
  end
  defp _accessor(_key, {:ok, _anything}) do
    {:halt, :error}
  end
end

defmodule NestedMap.Fetcher do
  use NestedMap.Types

  @moduledoc """
  Implements deep access to nested values
  """

  @doc false
  @spec fetch(map(), list()) :: result_t()
  def fetch(map, keys), do: Enum.reduce_while(keys, {:ok, map}, &_accessor/2)

  @spec _accessor(any(), ok_t()) :: {:cont, ok_t()} | {:halt, :error}
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

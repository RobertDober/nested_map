defmodule NestedMap.Fetcher do
  use NestedMap.Types

  @moduledoc """
  Implements deep access to nested values
  """

  @doc false
  @spec fetch(map(), list()) :: result_t()
  def fetch(map, keys), do: Enum.reduce_while(keys, {:ok, map}, &_accessor/2)

  @doc false
  @spec find(flattened_map_t(), list()) :: any()
  def find(flattened, keys) do
    flattened
    |> Enum.find_value(&_access_value(&1, keys))
  end

  @spec _access_value(flattend_map_entry_t(), list()) :: any()
  defp _access_value({key, value}, searched_key) do
    if key == searched_key do
      value
    end
  end

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

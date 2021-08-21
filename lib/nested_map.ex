defmodule NestedMap do
  @moduledoc """
    `NestedMap` provides tools to treat nested maps (that came as a surprise),
    notably:

    - accessing nested values with a list of keys
    - flatting a nested map to a list of pairs of list of keys and values
    - nested merging

    ### Flatting


    iex(0)> flatten(%{}) # empty
    []

    iex(0)> flatten(%{a: 1, b: 2}) # flat
    [{[:a], 1}, {[:b], 2}]

  """

  def flatten(map), do: map |> Enum.into([]) |> NestedMap.Flattener.flatten([], [])

  @doc """
  Used by the `xtra` mix task to generate the latest version in the docs, but
  also handy for client applications for quick exploration in `iex`.
  """
  def version() do
    with {:ok, version} = :application.get_key(:nested_map, :vsn),
      do: to_string(version)
  end
end

defmodule NestedMap do
  use NestedMap.Types
  @moduledoc """
    `NestedMap` provides tools to treat nested maps (that came as a surprise),
    notably:

    - accessing nested values with a list of keys
    - flatting a nested map to a list of pairs of list of keys and values
    - nested merging

    ## Complexity

    When describing complexities we assume `n` total entries (length of flattened list) with
    a maximum depth of `k` (maximum length of key list). We do not define a bound other than
    `O(n)` for the number of elements of depth `k` and therefore define `m = n*k`

    ### Accessing

    Is of complexity `O(k)` of course

    #### Basic interface

      iex(0)> fetch(%{}, :a) # not found
      :error

      iex(1)> fetch(%{b: 2}, :a, 42) # default
      {:ok, 42}

      iex(2)> fetch(%{a: 2}, :a, 42) # default
      {:ok, 2}

      iex(3)> fetch(%{a: 41}, :a) # found
      {:ok, 41}

      iex(4)> fetch!(%{a: 41}, :a)
      41

      iex(5)> fetch!(%{}, :a, 42)
      42

      iex(6)> try do
      ...(6)>   fetch!(%{}, :a)
      ...(6)> rescue
      ...(6)>   NestedMap.Error -> :caught
      ...(6)> end
      :caught

    #### Applied to nests

      iex(7)> map = %{
      ...(7)>   a: 1,
      ...(7)>   b: %{
      ...(7)>      c: %{
      ...(7)>         a: 100,
      ...(7)>         b: 200
      ...(7)>         },
      ...(7)>      d: 40}}
      ...(7)> {fetch(map, [:b, :c]), fetch(map, [:b, :c, :b]), fetch!(map, [:b, :x], :not_found)}
      {{:ok, %{a: 100, b: 200}}, {:ok, 200}, :not_found}



    ### Flattening

    The complexity is `O(m)`

      iex(8)> flatten(%{}) # empty
      []

      iex(9)> flatten(%{a: 1, b: 2}) # flat
      [{[:a], 1}, {[:b], 2}]

      iex(10)> map = %{
      ...(10)>   a: 1,
      ...(10)>   b: %{
      ...(10)>      ["you", "can"] => %{
      ...(10)>          "do" => "that",
      ...(10)>          "if" => %{you: :want}
      ...(10)>      },
      ...(10)>      the_inevitable: 42},
      ...(10)>   c: 2}
      ...(10)> flatten(map) # Be aware that this syntax puts the symbol key
      ...(10)>              # `the_inevitable` before the other keys!
      [{[:a], 1}, {[:b, :the_inevitable], 42}, {[:b, ["you", "can"], "do"], "that"}, {[:b, ["you", "can"], "if", :you], :want}, {[:c], 2}]

    #### Accessing flattened elements

      iex(11)> flattened =
      ...(11)>   [ {[:a, :a, :a, :a, :b], 1},
      ...(11)>     {[:a, :a, :a, :b], 1},
      ...(11)>     {[:a, :a, :b], 2},
      ...(11)>     {[:a, :b], 3},
      ...(11)>     {[:b], 4} ]
      ...(11)> find(flattened, [:a, :a, :b])
      2


    ### Deepening

    The complexity = `O(k) * O(n) * he complexity of Map.merge`

      iex(12)> flattened =
      ...(12)>   [ {[:a, :a, :a, :a, :b], 1},
      ...(12)>     {[:a, :a, :a, :b], 1},
      ...(12)>     {[:a, :a, :b], 2},
      ...(12)>     {[:a, :b], 3},
      ...(12)>     {[:b], 4} ]
      ...(12)> deepen(flattened)
      %{a: %{a: %{a: %{a: %{b: 1}, b: 1}, b: 2}, b: 3}, b: 4}

    #### One can pass a list that does not represent a flattened map

      iex(13)> impossible =
      ...(13)>   [ {[:a, :a, :a, :a, :b], 1},
      ...(13)>     {[:a, :a, :b], 2},
      ...(13)>     {[:a, :a, :b, :b], 3}, # %{a: %{a: %{b: value}}} value was not a map according
      ...(13)>                            # to the previous line
      ...(13)>     {[:a, :b], 4},
      ...(13)>     {[:b], 5} ]
      ...(13)> deepen(impossible) # the entry {[:a, :a, :b], 2} will simply be overwritten
      %{a: %{a: %{a: %{a: %{b: 1}}, b: %{b: 3}}, b: 4}, b: 5}

    A consequence of this is that, while this assumption holds for all maps

         deepen(flatten(map)) == map

    the symmetric assumption

        flatten(deepen(list)) == list

    does not, **even** if `list` is of the appropriate type, meaning that
    `deepen(list)` returns a map.

      iex(14)> tail =
      ...(14)> [ {[:a, :b, :c], 1},
      ...(14)>   {[:a, :b], 3} ]
      ...(14)> deepen(tail)
      %{a: %{b: 3}}


  """

  @doc false
  def deepen(flattened), do: NestedMap.Deepener.deepen(flattened)

  @doc false
  @spec find(flattened_map_t(), list()) :: any()
  def find(flattened, keys), do: NestedMap.Fetcher.find(flattened, keys)

  @doc false
  @spec flatten(map()) :: flattened_map_t()
  def flatten(map), do: map |> Enum.into([]) |> NestedMap.Flattener.flatten([], [])

  @doc false
  def fetch(map, keys)
  def fetch(map, keys) when is_list(keys) do
    NestedMap.Fetcher.fetch(map, keys)
  end
  def fetch(map, keys) do
    fetch(map, [keys])
  end
  def fetch(map, keys, default) do
    case fetch(map, keys) do
      :error -> {:ok, default}
      result -> result
    end
  end

  @doc false
  def fetch!(map, keys) do
    case fetch(map, keys) do
      {:ok, value} -> value
      :error       -> raise NestedMap.Error, "keys not found #{inspect keys}"
    end
  end
  def fetch!(map, keys, default) do
    with {:ok, value} <- fetch(map, keys, default) do
       value
    end
  end

  @doc """
  Used by the `xtra` mix task to generate the latest version in the docs, but
  also handy for client applications for quick exploration in `iex`.
  """
  @spec version() :: binary()
  def version() do
    with {:ok, version} = :application.get_key(:nested_map, :vsn),
      do: to_string(version)
  end
end
#  SPDX-License-Identifier: Apache-2.0

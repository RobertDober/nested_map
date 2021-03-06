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

    The complexity = `O(k) * O(n) * the complexity of Map.merge`

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

    ### Merging

    is now a trivial task as it can be done as follows

        (1) flatten lhs and rhs into arrays
        (2) make these arrays maps with the compound keys
        (3) merge these maps
        (4) make the resulting map a flattened array again
        (5) deepen this into a map,

    voil??.

    here is a short demonstration:

      iex(15)> a = %{a: %{b: 1, c: 2}}
      ...(15)> b = %{a: %{b: 2, d: 3}}
      ...(15)> amap = a |> flatten() |> Enum.into(%{})
      ...(15)> bmap = b |> flatten() |> Enum.into(%{})
      ...(15)> Map.merge(amap, bmap) |> flatten() |> Enum.map(fn {[keys], value} -> {keys, value} end) |> deepen()
      %{a: %{b: 2, c: 2, d: 3}}

    of course this is implemented in a convenience function `merge` which has the complexity of deepen, in our case
    `O(K) * O(S) * Complexity of Map.merge` where `K = max (k_of_a, k_of_b) && S = n_of_a + n_of_b` 

      iex(16)> a = %{a: %{b: 1, c: %{d: 2}}, x: 100}
      ...(16)> b = %{a: %{b: 3, c: %{e: 4}}, y: 200}
      ...(16)> merge(a, b)
      %{a: %{b: 3, c: %{d: 2, e: 4}}, x: 100, y: 200}

    #### Conflict resolution

    is done as with `Map.merge`

      iex(17)> a = %{a: %{b: 1, c: %{d: 2}}, x: 100}
      ...(17)> b = %{a: %{b: 3, c: %{e: 4}}, y: 200}
      ...(17)> merge(a, b, fn _, lhs, rhs -> lhs + rhs end)
      %{a: %{b: 4, c: %{d: 2, e: 4}}, x: 100, y: 200}

    ### Creating nested maps

    The `make_nested_map` function supports a _normal_ format

        iex(18)> make_nested_map([:a, :b, :c], 42)
        %{a: %{b: %{c: 42}}}

    and one that is adapted to iterate over flattened representations

        iex(19)> make_nested_map({[:a, :b, :c], 42})
        %{a: %{b: %{c: 42}}}

  """

  @spec deepen(flattened_map_t()) :: map()
  def deepen(flattened), do: NestedMap.Deepener.deepen(flattened)

  @spec find(flattened_map_t(), list()) :: any()
  def find(flattened, keys), do: NestedMap.Fetcher.find(flattened, keys)

  @spec flatten(map()) :: flattened_map_t()
  def flatten(map), do: map |> Enum.into([]) |> NestedMap.Flattener.flatten([], [])

  @spec fetch(map(), any()) :: result_t()
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

  @spec fetch!(map(), any()) :: any() | no_return()
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

  @spec make_nested_map(list(), any()) :: map()
  def make_nested_map(keys, value), do: make_nested_map({keys, value})

  @spec make_nested_map(flattend_map_entry_t()) :: map()
  def make_nested_map({keys, value}) do
    keys
    |> Enum.reverse()
    |> Enum.reduce(value, fn k, result -> %{k => result} end)
  end

  @spec merge(map(), map()) :: map()
  def merge(lhs, rhs) do
    lmap = lhs |> flatten() |> Enum.into(%{})
    rmap = rhs |> flatten() |> Enum.into(%{})
    Map.merge(lmap, rmap)
      |> flatten() |> Enum.map(fn {[keys], value} -> {keys, value} end)
      |> deepen()
  end

  @spec merge(map(), map(), (any(), any(), any() -> any())) :: map()
  def merge(lhs, rhs, fun) do
    lmap = lhs |> flatten() |> Enum.into(%{})
    rmap = rhs |> flatten() |> Enum.into(%{})
    Map.merge(lmap, rmap, fun)
      |> flatten() |> Enum.map(fn {[keys], value} -> {keys, value} end)
      |> deepen()
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

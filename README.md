
<!--
DO NOT EDIT THIS FILE
It has been generated from the template `README.md.eex` by Extractly (https://github.com/RobertDober/extractly.git)
and any changes you make in this file will most likely be lost
-->

# NestedMap

[![CI](https://github.com/RobertDober/nested_map/actions/workflows/ci.yml/badge.svg)](https://github.com/RobertDober/nested_map/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/RobertDober/nested_map/badge.svg?branch=main)](https://coveralls.io/github/RobertDober/nested_map?branch=main)
[![Hex.pm](https://img.shields.io/hexpm/v/nested_map.svg)](https://hex.pm/packages/nested_map)
[![Hex.pm](https://img.shields.io/hexpm/dw/nested_map.svg)](https://hex.pm/packages/nested_map)
[![Hex.pm](https://img.shields.io/hexpm/dt/nested_map.svg)](https://hex.pm/packages/nested_map)


**N.B.**

This README contains the docstrings and doctests from the code by means of [extractly](https://hex.pm/packages/extractly)
and the following code examples are therefore verified with `ExUnit` doctests.

## Dependency

    { :nested_map, ">= 0.1.1" }

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

  voilà.

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




## Contributing

Pull Requests are happily accepted.

Please be aware of one _caveat_ when correcting/improving `README.md`.

The `README.md` is generated by `Extractly` as mentioned above and therefore contributers shall not modify it directly, but
`README.md.eex` and the imported docs instead.


## Author

Copyright © 2021 Robert Dober robert.dober@gmail.com

# LICENSE

Same as Elixir, which is Apache License v2.0. Please refer to [LICENSE](LICENSE) for details.

SPDX-License-Identifier: Apache-2.0

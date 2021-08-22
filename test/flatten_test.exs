defmodule Test.FlattenTest do
  use ExUnit.Case

  @moduletag timeout: 10_000
  @n 10_000

  test "assure iteration" do
    flattened =
      1..@n
      |> Enum.reduce(%{b: 1}, fn k, acc -> %{a: acc, b: k} end)
      |> NestedMap.flatten
    half = Integer.floor_div(@n, 2)
    keys =
      1..half
      |> Enum.reduce([:b], fn _, a -> [:a|a] end)

    assert NestedMap.find(flattened, keys) == half
  end

end

defmodule Test.FlattenAndDeepenTest do
  use ExUnit.Case
  

  describe "edge cases" do
    test "empty" do
      assert_idem %{}
    end
    test "singleton" do
      assert_idem %{a: 1}
    end
  end

  defp assert_idem(map) do
    assert _flatten_and_deepen(map) == map
  end

  defp _flatten_and_deepen(map) do
    map
    |> NestedMap.flatten
    |> NestedMap.deepen
  end

end

defmodule Test.FlattenAndDeepenTest do
  use ExUnit.Case
  import NestedMap, only: [deepen: 1, flatten: 1]
  import Test.Support.RandomMap

  @tests 200
  @n 1000
  describe "property test" do
    (1..@tests)
      |> Enum.each(fn test_n ->
          expected = rand_flattened_elements(@n) |> deepen()
          result = expected |> flatten() |> deepen()
          quote do
            unquote do
              test("property #{test_n}") do
                result = unquote(Macro.escape(result))
                expected = unquote(Macro.escape(expected))
                assert result == expected
              end
            end
          end
      end)
  end

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

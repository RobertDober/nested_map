defmodule NestedMapTest do
  use ExUnit.Case
  doctest NestedMap, import: true

  @requested_format ~r{\A \d+ \. \d+ \. \d+ \z}x
  test "version string" do
    assert Regex.match?(@requested_format, NestedMap.version())
  end

end

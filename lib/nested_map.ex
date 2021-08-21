defmodule NestedMap do
  @moduledoc """
    `NestedMap` provides tools to treat nested maps (that came as a surprise),
    notably:

    - accessing nested values with a list of keys
    - flatting a nested map to a list of pairs of list of keys and values
    - nested merging

  """

  def version() do
    with {:ok, version} = :application.get_key(:nested_map, :vsn),
      do: to_string(version)
  end
end

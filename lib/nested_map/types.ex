defmodule NestedMap.Types do
  defmacro __using__(_opts) do
    quote do
      @type pair_t :: {any(), any()}
      @type flattend_map_entry_t :: {list(), any()}
      @type flattened_map_t :: list(flattend_map_entry_t())
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0

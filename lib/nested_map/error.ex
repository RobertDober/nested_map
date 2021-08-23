defmodule NestedMap.Error do

  @moduledoc false

  defexception [:message]

  @type t :: %__MODULE__{__exception__: true, message: binary()}

  @doc false
  @spec exception(binary()) :: t()
  def exception(msg), do: %__MODULE__{message: msg}

end

# SPDX-License-Identifier: Apache-2.0

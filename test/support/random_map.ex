defmodule Test.Support.RandomMap do

  def rand_flattened_elements(n, max_depth \\ 10, keys \\ [:a, :b, :c, :d, :e, :f, :g, :h]) do
    _rand_range(1..n)
    |> Enum.map(&{_make_keys(max_depth, keys), &1})
  end

  defp _make_keys(max_depth, keys) do
    _rand_range(1..max_depth)
    |> Enum.map(fn _ -> _rand(keys) end)
  end

  defp _rand(n)
  defp _rand(%Range{first: f, last: l}), do: f + _rand(l + 1 - f)
  defp _rand(list) when is_list(list) do
    l = Enum.count(list)
    list |> Enum.at(_rand(l))
  end
  defp _rand(n), do: (n * :rand.uniform) |> trunc()

  defp _rand_range(%Range{first: f}=range), do: f.._rand(range)

end

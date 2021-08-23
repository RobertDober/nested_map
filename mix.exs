defmodule NestedMap.MixProject do
  use Mix.Project

  def project do
    [
      app: :nested_map,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      #
      #
      {:deep_merge, "~> 1.0.0", only: [:dev]},
      {:dialyxir, "~> 1.1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.14.2", only: ~w[test]a},
      {:extractly, "~> 0.3.0", only: ~w[dev]a},

      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

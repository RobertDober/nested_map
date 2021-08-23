defmodule NestedMap.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/RobertDober/nested_map"

  @description """
  NestedMap Tools to work with nested maps / merging / flattening / deepening / simple deep access
  """

  def project do
    [
      app: :nested_map,
      description: @description,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),
      aliases: [docs: &build_docs/1],

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

  defp elixirc_paths(env)
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: [
        "Robert Dober <robert.dober@gmail.com>"
      ],
      licenses: [
        "Apache-2.0"
      ],
      links: %{
        "GitHub" => @url},
    ]
  end
  @prerequisites """
  run `mix escript.install hex ex_doc` and adjust `PATH` accordingly
  """
  @module "NestedMap"
  defp build_docs(_) do
    Mix.Task.run("compile")
    ex_doc = Path.join(Mix.path_for(:escripts), "ex_doc")
    Mix.shell().info("Using escript: #{ex_doc} to build the docs")

    unless File.exists?(ex_doc) do
      raise "cannot build docs because escript for ex_doc is not installed, make sure to \n#{
              @prerequisites
            }"
    end

    args = [@module, @version, Mix.Project.compile_path()]
    opts = ~w[--main #{@module} --source-ref v#{@version} --source-url #{@url}]

    Mix.shell().info("Running: #{ex_doc} #{inspect(args ++ opts)}")
    System.cmd(ex_doc, args ++ opts)
    Mix.shell().info("Docs built successfully")
  end
end

#  SPDX-License-Identifier: Apache-2.0

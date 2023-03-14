defmodule GeneticVrp.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetic_vrp,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GeneticVrp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.5"},
      {:plug_cowboy, "~> 2.5.2"},
      {:poison, "~> 5.0"},
      {:credo, "~> 1.6"}
    ]
  end
end

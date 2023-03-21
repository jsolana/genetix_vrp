defmodule GenetixVrp.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetix_vrp,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      deps: deps(),
      name: "GenetixVrp",
      package: package(),
      source_url: "https://github.com/jsolana/genetix_vrp",
      homepage_url: "https://github.com/jsolana/genetix_vrp",
      docs: docs()
    ]
  end

  defp description() do
    "Service that solve Vehicle Routing Problems (VRP) with genetic algorithm"
  end

  defp package() do
    %{
      maintainers: ["Javi Solana"],
      links: %{"GitHub" => "https://github.com/jsolana/genetix_vrp"}
    }
  end

  defp docs() do
    [
      # The main page in the docs
      main: "GenetixVrp",
      logo: "guides/logo.png",
      extras: ["README.md", "guides/documentation.md"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GenetixVrp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:genetix, "~> 0.1.0"},
      {:tesla, "~> 1.5"},
      {:plug_cowboy, "~> 2.5.2"},
      {:poison, "~> 5.0"},
      {:credo, "~> 1.6"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end
end

defmodule Underthehood.MixProject do
  use Mix.Project

  def project do
    [
      app: :underthehood,
      description: description(),
      version: "0.1.5",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "Underthehood",
      source_url: github_url(),
      docs: [
        extras: ["README.md", "LICENSE.md"],
        main: "readme"
      ]
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
      {:phoenix_live_view, "~> 0.17"},
      {:extty, "~> 0.2"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A collection of LiveView components for embedding IEx terminals into web pages."
  end

  defp package do
    [
      files: ~w(assets lib .formatter.exs mix.exs README.md LICENSE.md),
      licenses: ["MIT"],
      links: %{"GitHub" => github_url()}
    ]
  end

  defp github_url do
    "https://github.com/frerich/underthehood"
  end
end

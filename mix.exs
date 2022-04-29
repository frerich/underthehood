defmodule Underthehood.MixProject do
  use Mix.Project

  def project do
    [
      app: :underthehood,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
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
      {:phoenix_live_view, "~> 0.17"},
      {:extty, "~> 0.2"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end

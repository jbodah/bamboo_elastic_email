defmodule BambooElasticEmail.MixProject do
  use Mix.Project

  def project do
    [
      app: :bamboo_elastic_email,
      version: "0.1.0",
      elixir: "~> 1.5",
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
      {:bamboo, "~> 0.7.0"},
      {:cowboy, "~> 1.0", only: [:test, :dev]}
    ]
  end
end

defmodule Load.MixProject do
  use Mix.Project

  def project do
    [
      app: :load,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Load.Application, []}
    ]
  end

  defp deps do
    [
      {:hackney, "~> 1.15.0"},
      {:jason, "~> 1.0"}
    ]
  end
end

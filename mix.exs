defmodule Geoff.Mixfile do
  use Mix.Project

  def project do
    [app: :geoff,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger],
     mod: {Geoff, []}]
  end

  defp deps do
    [
      {:roombex, "~> 0.0.5"},
    ]
  end
end

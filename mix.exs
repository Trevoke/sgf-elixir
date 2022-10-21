defmodule ExSgf.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_sgf,
      version: "0.3.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      source_url: "https://github.com/Trevoke/sgf-elixir",
      homepage_url: "https://github.com/Trevoke/sgf-elixir",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rose_tree, "~> 0.2.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Parsing SGF files."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Trevoke/sgf-elixir"}
    ]
  end
end

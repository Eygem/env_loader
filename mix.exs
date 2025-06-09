defmodule EnvLoader.MixProject do
  use Mix.Project

  def project do
    [
      app: :env_loader,
      version: "0.1.0",
      elixir: "~> 1.12",
      description:
        "A lightweight, dependency-free Elixir library for loading .env files into the system environment. Built for simplicity and robustness, it handles edge cases like comments, quoted values, EXPORT directives, empty keys, and inline comments with fewer than 60 lines of code.",
      package: package(),
      deps: deps(),
      name: "EnvLoader",
      source_url: "https://github.com/eygem/env_loader",
      docs: [
        main: "EnvLoader",
        extras: ["README.md"]
      ]
    ]
  end

  defp deps do
    [
      # For generating docs
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/eygem/env_loader"}
    ]
  end
end

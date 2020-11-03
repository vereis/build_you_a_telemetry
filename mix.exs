defmodule Telemetry.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :build_you_a_telemetry,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_options: [warnings_as_errors: true],
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      source_url: "https://github.com/vereis/build_you_a_telemetry",
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Telemetry.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [lint: ["format --check-formatted --dry-run", "credo --strict", "dialyzer"]]
  end

  defp description() do
    """
    Example minimal re-implementation of the `:telemetry` library.

    See project `README.md` for more details
    """
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/vereis/build_you_a_telemetry",
        "Homepage" => "https://cbailey.co.uk/posts/build_you_a_telemetry_for_such_learn"
      }
    ]
  end
end

defmodule WxEx.MixProject do
  use Mix.Project

  @source_url "https://github.com/kerryb/wx_ex"

  def project do
    [
      app: :wx_ex,
      version: "0.3.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:wx_ex | Mix.compilers()],
      package: package(),
      description: "Elixir wrappers for the Erlang macros in the wx package.",
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :wx]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:wx_ex_compiler, "> 0.0.0", runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Kerry Buckley"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kerryb/wx_ex"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md": [title: "WxEx"]]
    ]
  end
end

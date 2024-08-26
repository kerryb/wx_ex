defmodule WxEx.Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :wx_ex_core,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:wx_ex | Mix.compilers()]
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
      {:styler, "~> 1.0", only: [:dev, :test], runtime: false},
      {:wx_ex_compiler, in_umbrella: true}
    ]
  end
end

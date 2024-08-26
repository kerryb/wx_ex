defmodule WxEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :wx_ex_core,
      version: "0.1.0",
      elixir: "~> 1.15",
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
      {:wx_ex_compiler, github: "kerryb/wx_ex_compiler"}
    ]
  end
end

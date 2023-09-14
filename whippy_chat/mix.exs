defmodule WhippyChat.MixProject do
  use Mix.Project

  def project do
    [
      app: :whippy_chat,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WhippyChat.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0-pre"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, "~> 0.16.3"}
    ]
  end
end

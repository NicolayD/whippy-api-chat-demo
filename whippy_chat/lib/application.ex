defmodule WhippyChat.Application do
  @moduledoc """
  Documentation for `WhippyChat`.
  """

  use Application

  def start(_type, _args) do
    children = [
      {Bandit, plug: WhippyChat.Plug, port: 4001}
    ]

    opts = [strategy: :one_for_one, name: WhippyChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

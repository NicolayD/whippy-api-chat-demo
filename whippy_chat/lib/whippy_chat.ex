defmodule WhippyChat do
  @moduledoc """
  Documentation for `WhippyChat`.
  """

  def start(_type, _args) do
    children = [
      {Bandit, plug: WhippyChat.Plug}
    ]

    opts = [strategy: :one_for_one, name: WhippyChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

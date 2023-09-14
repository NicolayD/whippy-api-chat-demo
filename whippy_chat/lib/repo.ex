defmodule WhippyChat.Repo do
  use Ecto.Repo,
    otp_app: :whippy_chat,
    adapter: Ecto.Adapters.Postgres
end

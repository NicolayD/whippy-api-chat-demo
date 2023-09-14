import Config

config :whippy_chat, WhippyChat.Repo,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  ssl_opts: [verify: :verify_none]

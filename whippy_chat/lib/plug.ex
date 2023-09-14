defmodule WhippyChat.Plug  do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    IO.inspect System.get_env("WHIPPY_API_KEY")
    IO.inspect System.get_env("OPENAI_API_KEY")
    IO.inspect System.get_env("DATABASE_URL")

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello World!\n")
  end
end

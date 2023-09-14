defmodule WhippyChat.Plug  do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    {:ok, payload, _conn} = Plug.Conn.read_body(conn)

    message = payload
      |> Jason.decode!()
      |> Map.fetch!("data")
      |> IO.inspect

    Task.start(fn -> WhippyChat.Bot.classify(message) end)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello from Whippy Chat!\n")
  end
end

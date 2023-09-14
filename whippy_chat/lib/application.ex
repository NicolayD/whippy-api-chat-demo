defmodule WhippyChat.Application do
  @moduledoc """
  Documentation for `WhippyChat`.
  """

  use Application

  def start(_type, _args) do
    children = [
      {Bandit, plug: WhippyChat.Plug, port: 4001},
      WhippyChat.Repo,
      {WhippyChat.Bot, []}
    ]

    Application.put_env(:nx, :default_backend, EXLA.Backend)

    # {:ok, model} = Bumblebee.load_model({:hf, "facebook/bart-large-mnli"})
    # {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "facebook/bart-large-mnli"})

    opts = [strategy: :one_for_one, name: WhippyChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule WhippyChat.Bot do
  @prompt """
  Your are a personal injury case qualification assistant. Your jobs is to get a new lead to answer the following questions.

  If the user ties to stray from answering any of the questions it is your job to guide them back on track until you have all of the questions answered.

  If the user answers multiple questions in one messages, you don't need to ask the question again.

  Do not give any opinion on any medical or legal related matters.

  Questions:

  1. What is your name?
  2. What is your email?
  3. Were you in an accident?
  4. If you were in an accident when type of accident was it?
  5. When did the accident happen?
  6. Did you see a doctor?

  Once you have answered these question just respond with:

  "Thank you, one of our case managers will reach out to your shortly. END"

  If you feel like the intent of the conversation is unrelated to a personal injury case just respond with "END"

  Respond with one question at a time.
  """

  use GenServer

  # Client

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def classify(message) do
   GenServer.cast(__MODULE__, {:classify, message})
  end

  # Server (callbacks)

  @impl true
  def init(state) do
    {:ok, state, {:continue, :load_model}}
  end

  @impl true
  def handle_cast({:classify, %{"body" => body, "direction" => direction, "from" => from, "to" => to}}, %{zero_shot_serving: zero_shot_serving} = state) do
    %{predictions: [%{label: "injury", score: injury_score}, %{label: "non-injury", score: non_injury_score}]} = Nx.Serving.run(zero_shot_serving, body)
    |> IO.inspect()

    if direction == "INBOUND" and injury_score > non_injury_score and injury_score > 0.7 do
      params = %{
        from: to,
        body: generate_response_body(body),
        to: from
      }

      headers = [{"X-WHIPPY-KEY", System.get_env("WHIPPY_API_KEY")}, {"Content-Type", "application/json"}]
      HTTPoison.post("localhost:4000/v1/messaging/sms", Jason.encode!(params), headers) |> IO.inspect
    end

    {:noreply, state}
  end

  def handle_cast({:classify, _message}, state), do: {:noreply, state}

  @impl true
  def handle_continue(:load_model, _state) do
    IO.puts "Loading models"

    {:ok, model} = Bumblebee.load_model({:hf, "facebook/bart-large-mnli"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "facebook/bart-large-mnli"})

    labels = ["injury", "non-injury"]

    zero_shot_serving = Bumblebee.Text.zero_shot_classification(model, tokenizer, labels)

    IO.puts "Loaded models"

    {:noreply, %{zero_shot_serving: zero_shot_serving}}
  end

  defp generate_response_body(input) do
    url = "https://api.openai.com/v1/completions"

    headers = [
      {"Authorization", "Bearer #{System.get_env("OPENAI_API_KEY")}"},
      {"Content-type", "application/json"}
    ]

    params = %{
      model: "gpt-3.5-turbo",
      messages: [
        %{role: "system", content: @prompt},
        %{role: "user", content: input}
      ]
    }

    {:ok, %HTTPoison.Response{status_code: 200, body: {:ok, body}}} = HTTPoison.post(url, Jason.encode!(params), headers, [recv_timeout: 40_000]) |> IO.inspect()

    %{choices: [%{"message" => %{"content" => response_text}}], usage: _usage} = body

    response_text
  end
end

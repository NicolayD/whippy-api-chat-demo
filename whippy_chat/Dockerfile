FROM elixir:1.14

# Prepare build dir
ADD ./* $HOME/

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

RUN mix deps.get

CMD ["mix", "run", "--no-halt"]

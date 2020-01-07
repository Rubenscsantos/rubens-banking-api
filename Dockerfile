FROM elixir:1.9.4-alpine

WORKDIR app

COPY mix.exs .
COPY mix.lock .
COPY VERSION .

RUN apk add --update postgresql-client make tzdata git inotify-tools

ARG MIX_ENV=dev
ENV MIX_ENV=$MIX_ENV

RUN mix do local.hex --force, local.rebar --force

RUN mix do deps.get, deps.clean --unused, compile

CMD ["sh", "-c", "mix phx.server --no-halt"]
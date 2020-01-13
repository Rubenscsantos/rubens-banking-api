FROM elixir:1.9.4-alpine

WORKDIR /app

COPY . /app

RUN apk add --update postgresql-client tzdata git inotify-tools npm make gcc libc-dev

ARG MIX_ENV=dev
ENV MIX_ENV=$MIX_ENV

RUN mix do local.hex --force, local.rebar --force

RUN mix do deps.get, deps.clean --unused, compile

CMD ["sh", "-c", "mix phx.server --no-halt"]
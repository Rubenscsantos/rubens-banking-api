# RubensBankingApi

## Requirements

Using your favorite package manager install

- [Docker](https://docs.docker.com/compose/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Postman](https://www.getpostman.com/)

make sure you are in the Docker group by doing

```shell
$ sudo gpasswd -a YOUR_USER docker
```

# Running the containers

- `make down` - Stops the containers
- `make test-shell` - Build containers test environment and connects to shell
- `docker-compose up --build` - Build containers and run mix phx.server

# Testing

Inside the Docker image, the following commands are available (`make test-shell`)

- `mix test` - Runs the tests
- `iex -S mix` - Opens the elixir interactive shell
- `mix credo --strict --verbose` - Runs Credo, a linter
- `mix format` - Runs `mix format`

Install NPM then run `npm install` to install the pre-commit package.

# Documentation

## API Docs

- [Postman](./RubensBankingApi.postman_collection.json)

# Running the application

Run the `docker-compose up --build` command to start the application.
When it's up you can use Postman to make requests to `http://localhost:4000`.

The Postman collection is divided in folders, in order to be able to make the requests in the `Account` and `AccountTransaction` folders you need to be authenticated. You can do that by doing the POST request inside the `User` folder to create a new User, then doing the POST request inside the `Authentication` folder in order to Sign In.
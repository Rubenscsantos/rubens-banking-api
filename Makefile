# Auxiliary commands

.PHONY: mix-deps
mix-deps:
	mix deps.get

.PHONY: wait-db
wait-db:
	@echo 'Waiting Postgres Server...'
	@while ! nc -z db 5432; do sleep 1; done

.PHONY: db
db: mix-deps wait-db
	mix do ecto.create, ecto.migrate

.PHONY: setup
setup:
	npm install -C assets/
	mix phx.server

.PHONY: test-shell
test-shell:
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test.yml \
		build

	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.test.yml \
		run --rm app sh -c "make db && /bin/sh"

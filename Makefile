# Development targets
# -------------------

.PHONY: setup
setup: deps create-db ## Initial project setup (deps + database)

.PHONY: deps
deps: ## Install project dependencies
	mix deps.get
	npm install --prefix assets
	cd elixir-blueprint && make deps

.PHONY: boot-db
boot-db: ## Boot the database
ifeq ($(shell docker ps -a -q -f name=css_clash_postgres),)
	@echo "Booting database..."
	@docker remove css_clash_postgres-dev
	@docker build -t css_clash_postgres -f infra/db.Dockerfile .
	@docker run -d --name css_clash_postgres-dev -p 5432:5432 css_clash_postgres
	@mix ecto.create
	@echo "Database booted!"
else
	@echo "Database already running!"
endif

.PHONY: stop-db
stop-db: ## Stop the dev database
	@echo "Stopping database..."
	@docker stop css_clash_postgres-dev
	@docker rm css_clash_postgres-dev
	@echo "Database stopped!"

.PHONY: create-db
create-db: boot-db ## Create the local database
	@mix ecto.create
	@echo "Running DB setup script..."
	@mix run priv/repo/setup_local_db.exs
	@echo "Running migrations..."
	@mix ecto.migrate
	@echo "Running seeds..."
	@mix run priv/repo/seeds.exs

.PHONY: drop-db ## Drop the local database
drop-db: boot-db
	@echo "Dropping database..."
	@mix ecto.drop
	@echo "Database dropped!"

.PHONY: reset-db ## Reset the local database
reset-db: drop-db create-db

.PHONY: start
start: start-server ## Boot the database and start dev server

.PHONY: migrate
migrate: boot-db ## Run the database migrations (after booting the database if necessary)
	mix ecto.migrate

.PHONY: start-server
start-server: ## Start the development server
	iex --sname css_clash --cookie livebook_cookie -S mix phx.server

.PHONY: deploy-start
deploy-start:
	/app/bin/migrate
	/app/bin/server

.PHONY: i18n-sync
i18n-sync: ## Extract and merge command combined for gettext
	mix gettext.extract
	mix gettext.merge priv/gettext --locale fr
	mix gettext.merge priv/gettext --locale en

.PHONY: test
test: ## Run tests
	MIX_ENV=test mix test

.PHONY: test-watch
test-watch: ## Run tests in watch mode
	MIX_ENV=test mix test.watch

.PHONY: format
format: ## Format code
	mix format
	mix credo --strict
	cd assets && npx eslint --fix .

.PHONY: check-for-warnings
check-for-warnings: ## Check for warnings in the codebase
	rm -rf _build/dev/lib/css_clash/
	mix compile --warnings-as-errors

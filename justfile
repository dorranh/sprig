default: install lint

install: install-client install-src

install-client:
  cd clients/python && poetry install

install-src:
  cd src && poetry install

lint-client:
  cd clients/python && poetry run pyright
  cd clients/python && poetry run ruff check

lint-src:
  cd src && poetry run pyright
  cd src && poetry run ruff check

lint: lint-client lint-src


default: install lint test

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

test-src:
  cd src && poetry run pytest

test: test-src

test-ui:
  cd ui/sprig_ui && flutter test

install-ui:
  cd ui/sprig_ui && flutter pub get

lint-ui:
  cd ui/sprig_ui && flutter analyze --no-fatal-infos

build-ui-macos:
  cd ui/sprig_ui && flutter build macos

build-ui-linux:
  cd ui/sprig_ui && flutter build linux

build-ui-windows:
  cd ui/sprig_ui && flutter build windows

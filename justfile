default: install lint test build

install: install-client

install-client:
  cd clients/python && poetry install

lint-client: install
  cd clients/python && poetry run pyright
  cd clients/python && poetry run ruff check

lint-src:
  cd src && cargo fmt --check
  cd src && cargo clippy

lint: lint-client lint-src

test: test-src

test-src:
  cd src && cargo test

build:
  cd src && cargo build

export PATH := justfile_directory() + "/src/target/debug:" + env_var('PATH')

test-integration: install build
  cd examples/python-script && poetry run --directory ../../clients/python -- python example-python-usage.py

# UI-specific recipes. Ideally we could include these in the combined recipes above in the future.

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

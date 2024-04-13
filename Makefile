# Setup development environment
setup:
	poetry install

# Devtools
hooks-install: setup
	poetry run pre-commit install

hooks-upgrade:
	poetry run pre-commit autoupdate

hooks-lint:
	poetry run pre-commit run --all-files

lint: hooks-lint  # alias

hooks-mypy:
	poetry run pre-commit run mypy --all-files

mypy: hooks-mypy  # alias

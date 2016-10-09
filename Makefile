SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

shellcheck: ## Run shellcheck on /scripts directory
	$(info --> Run shellsheck)
	find . -type f -name *.sh | xargs -n 1 shellcheck

test: ## Run test suite
	$(info --> Run test suite)
	make shellcheck
	@env \
		./tests/run.sh

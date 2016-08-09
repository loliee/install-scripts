SHELL := /usr/bin/env bash

.DEFAULT_GOAL := help

shellcheck: ## Run shellcheck on /scripts directory
	$(info --> Run shellsheck)
	@find . -type f -name *.bash | xargs -n 1 shellcheck

md5:
	$(info --> Generate md5 checksum files)
	@find .  -name *bash | xargs -P 4 -I % openssl md5 -r -out %.md5 %

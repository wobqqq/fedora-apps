SHELL := /bin/bash

SCRIPTS := $(wildcard *.sh) $(wildcard predator-pt316-51s/*.sh) $(wildcard lib/*.sh) $(wildcard tools/*.sh)
RUN := docker compose run --rm --quiet-pull

.PHONY: lint test links packages ready

lint:
	$(RUN) shellcheck -x -S style $(SCRIPTS)
	$(RUN) bash sh -c 'for f in $(SCRIPTS); do bash -n "$$f" || exit 1; done'

test:
	$(RUN) bats tests

links:
	docker compose build -q tools
	$(RUN) tools tools/check-links.sh

packages:
	$(RUN) fedora tools/check-packages.sh

ready: lint test

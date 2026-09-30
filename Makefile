SHELL := /bin/bash

SCRIPTS := $(wildcard *.sh) $(wildcard predator-pt316-51s/*.sh) $(wildcard lib/*.sh) $(wildcard tools/*.sh)
RUN := docker run --rm -v "$(CURDIR)":/repo -w /repo

.PHONY: lint test links packages ready

lint:
	$(RUN) koalaman/shellcheck:stable -x -S style $(SCRIPTS)
	$(RUN) bash:5 sh -c 'for f in $(SCRIPTS); do bash -n "$$f" || exit 1; done'

test:
	$(RUN) bats/bats:latest tests

links:
	docker build -q -t fedora-apps-tools docker/tools >/dev/null
	$(RUN) -e GITHUB_TOKEN fedora-apps-tools tools/check-links.sh

packages:
	$(RUN) fedora:latest tools/check-packages.sh

ready: lint test

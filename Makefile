SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help bootstrap bootstrap-user bootstrap-admin status doctor audit check public-check

help:
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

bootstrap: bootstrap-user ## Configure the current non-admin user

bootstrap-user: ## Apply idempotent user-owned configuration
	@./bootstrap.sh --user

bootstrap-admin: ## Install reviewed shared packages as the Homebrew owner
	@./bootstrap.sh --admin

status: ## Show running services and resource health
	@./scripts/diagnostics/status.sh

doctor: ## Check expected configuration and report drift
	@./scripts/diagnostics/doctor.sh

audit: ## Print a deeper read-only security inventory
	@./scripts/security/audit.sh

check: ## Validate repository scripts and configuration syntax
	@./tests/check.sh

public-check: ## Scan tracked content for secrets and host-specific details
	@./scripts/security/check-public.sh

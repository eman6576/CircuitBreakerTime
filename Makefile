## Makefile
# Commads for setup and running CircuitBreakerTime

.PHONY: help

# Target Rules
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

project:
	swift package generate-xcodeproj

open_xcodeproj:
	open CircuitBreakerTime.xcodeproj

build:
	swift build

clean: ## Resets and cleans the project
	swift package reset
	swift package clean

run: 
	./.build/debug/CircuitBreakerTime

run_linux: ## Complies and runs the project in Linux using Docker
	docker-compose up

# Target Dependencies
all: build project open_xcodeproj ## Complies, generates a new xcodeproj file and opens the project in Xcode

clean_all: clean all ### Reset and cleans, complies, generates a new xcodeproj file and opens the project in Xcode

run_local: build run ## Complies and runs the project locally
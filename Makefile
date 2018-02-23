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

# Endpoints
test_base: ## Tests the base url
	curl -X GET http://localhost:8090

test_swifty_success: ## Tests the success route for SGCircuitBreaker
	curl -X GET http://localhost:8090/swiftyguerrero/success

test_swifty_success_delay: ## Tests the success delay route for SGCircuitBreaker
	curl -X GET http://localhost:8090/swiftyguerrero/success-delay

test_swifty_failure: ## Tests the failure route for SGCircuitBreaker
	curl -X GET http://localhost:8090/swiftyguerrero/failure

test_ibm_success: ## Tests the success route for IBM-Swift CircuitBreaker
	curl -X GET http://localhost:8090/ibm/success

test_ibm_failure: ## Tests the failure route for IBM-Swift CircuitBreaker
	curl -X GET http://localhost:8090/ibm/failure

# Target Dependencies
all: build project open_xcodeproj ## Complies, generates a new xcodeproj file and opens the project in Xcode

clean_all: clean all ### Reset and cleans, complies, generates a new xcodeproj file and opens the project in Xcode

run_local: build run ## Complies and runs the project locally
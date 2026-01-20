BIN="bin"
BUILD_FILES = $(shell go list -f '{{range .GoFiles}}{{$$.Dir}}/{{.}}\
{{end}}' ./...)

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development
.PHONY: tidy
tidy: ## Run go mod tidy
	go mod tidy

.PHONY: fmt
fmt: ## Run go fmt against code.
	go fmt ./...

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...

.PHONY: lint
lint: ## Run golangci-lint
	golangci-lint run

.PHONY: lint-fix
lint-fix: ## Run golangci-lint and perform fixes
	golangci-lint run --fix

.PHONY: test
test: tidy fmt vet lint ## Run tests
	go test ./...
	echo "Check for uncommitted changes, e.g. by 'go mod tidy'"
	git diff --exit-code --name-only

.PHONY: clean
clean: ## Clean build artifacts
	rm -rf $(BIN)
	rm -rf dist

##@ Build
build: fmt vet $(BUILD_FILES) ## Build binary
	go build -o $(BIN)/my-go-template main.go

.PHONY:dry-run-release
dry-run-release: ## Release binary (dry run)
	goreleaser release --snapshot --skip=publish --clean

.PHONY:release
release: ## Release manager binary
	goreleaser release --clean

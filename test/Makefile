.DEFAULT_GOAL:=help

#============================================================================
# Load environment variables for local development


API_GATEWAY_HOST := localhost
API_GATEWAY_PORT := 8080

#============================================================================

.PHONY: prepare-k6
prepare-k6:		## Prepare K6
	@go version
	@go install go.k6.io/xk6/cmd/xk6@latest
	@xk6 build --with github.com/szkiba/xk6-jose@latest

.PHONY: cleanup-k6
cleanup-k6:		## Cleanup K6
	@rm k6


.PHONY: load-test
load-test:		## Test Text to Image model
	@TEST_FOLDER_ABS_PATH=${PWD} k6 run \
		-e API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT} \
		-e API_GATEWAY_PROTOCOL=http \
		./load/load_test.js --no-usage-report

.PHONY: help
help:       	## Show this help
	@echo "\nTest models"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

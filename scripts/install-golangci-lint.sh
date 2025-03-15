#!/bin/bash -eu
# shellcheck disable=SC2155

set -o pipefail

# renovate: datasource=github-releases depName=golangci/golangci-lint
GCI_VERSION="1.64.7"

echo "installing golangci-lint ${GCI_VERSION}"
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin "v${GCI_VERSION}"

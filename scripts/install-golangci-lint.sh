#!/bin/bash -eu
# shellcheck disable=SC2155

set -o pipefail

# renovate: datasource=github-releases depName=golangci/golangci-lint
GCI_VERSION="1.62.0"

echo "installing golangci-lint ${GCI_VERSION}"
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin "v${GCI_VERSION}"

# manually install for now, until https://github.com/golangci/golangci-lint/pull/3835 appears in a release.
# go install github.com/golangci/golangci-lint/cmd/golangci-lint@f08711794c0b3e4606eed0cadf1cc57c11737c01

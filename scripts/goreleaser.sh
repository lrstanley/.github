#!/bin/bash -eux
# shellcheck disable=SC2155

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

VERSION_GOREL="1.7.0"

curl -sSL \
	"https://github.com/goreleaser/goreleaser/releases/download/v${VERSION_GOREL}/goreleaser_Linux_x86_64.tar.gz" \
	| tar -C /usr/local/bin/ -xzvf-

chmod +x /usr/local/bin/goreleaser

# TODO: if not a tag, just run build command, and not release command.
# TODO: make sure dist folder is uploaded to artifacts.

env

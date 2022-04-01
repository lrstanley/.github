#!/bin/bash -eu
# shellcheck disable=SC2155

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

curl -sS \
	-o /usr/local/bin/codecov \
	https://uploader.codecov.io/latest/linux/codecov

chmod +x /usr/local/bin/codecov

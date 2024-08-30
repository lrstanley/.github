#!/bin/bash -eu
# shellcheck disable=SC2155

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

if [ -f "/usr/local/bin/svu" ]; then
	exit 0
fi

SVU_VERSION="2.2.0"

echo "installing svu ${SVU_VERSION}"
curl -sSL "https://github.com/caarlos0/svu/releases/download/v${SVU_VERSION}/svu_${SVU_VERSION}_linux_amd64.tar.gz" \
	| tar -C /usr/local/bin/ -xzvf- svu

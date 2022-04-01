#!/bin/bash -eu

set -o pipefail

SVU_VERSION=1.9.0
curl -sSL "https://github.com/caarlos0/svu/releases/download/v${SVU_VERSION}/svu_${SVU_VERSION}_linux_amd64.tar.gz" |
    tar -C /usr/local/bin/ -xzvf- svu

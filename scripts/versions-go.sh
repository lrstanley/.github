#!/bin/bash -eu
# shellcheck disable=SC2155

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

URI="https://raw.githubusercontent.com/actions/go-versions/main/versions-manifest.json"

ACTION="${1:?usage: $0 <action>}"

case "$ACTION" in
	latest)
		VERSION=$(
			curl -sSL "$URI" | jq -r '[.[] | select(.stable == true)][0].version'
		)
		echo "::set-output name=version::${VERSION}"
		echo "::set-output name=versions::[\"${VERSION}\"]"
		;;
	many)
		VERSIONS=$(
			curl -sSL "$URI" \
				| jq -c '.[].version' \
				| awk -F. -v minor="$NUM_MINOR" -v patch="$NUM_PATCH" 'seen[$1, $2]++ < patch && length(seen) <= minor' \
				| jq -sc '.[]'
		)
		echo "::set-output name=versions::${VERSIONS}"
		;;
	*)
		echo "::set-output name=version::${ACTION}"
		echo "::set-output name=versions::[\"${ACTION}\"]"
		;;
esac

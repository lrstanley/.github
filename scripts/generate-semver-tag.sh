#!/bin/bash -eux
# shellcheck disable=SC2155,SC2181

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

"${BASE}/scripts/install-svu.sh"

git config user.name "github-actions"
git config user.email "github-actions@github.com"

case "$METHOD" in
	major | minor | patch)
		git tag "$(svu "$METHOD")"
		;;
	alpha | rc)
		CURRENT=$(svu current --tag-mode=all-branches)
		if [ "$?" != 0 ]; then
			echo "error: svu unable to get current tag"
			exit 1
		fi

		BUILD="next.$(git rev-parse --short HEAD)"
		read -r PR_TYPE REV <<<"$(sed -rn 's:^v?[0-9]+\.[0-9]+\.[0-9]+-(alpha|rc)\.([0-9]+)(\+.*)?$:\1 \2:p' <<<"$CURRENT")"

		if [ -z "$PR_TYPE" ] || [ -z "$REV" ] || [ "$PR_TYPE" != "$METHOD" ]; then
			REV=0
			PR_TYPE="$METHOD"
			METHOD="patch"
		else
			REV=$((REV + 1))
			METHOD="current"
		fi

		git tag "$(svu "$METHOD" --tag-mode=all-branches --no-metadata)-${PR_TYPE}.${REV}+${BUILD}"
		;;
	custom)
		git tag "$CUSTOM"
		;;
	*)
		echo "error: unknown method"
		exit 1
		;;
esac

git push --tags

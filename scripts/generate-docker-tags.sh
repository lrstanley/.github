#!/bin/bash -eu
# shellcheck disable=SC2155

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

"${BASE}/scripts/install-svu.sh"

function sanitize {
	sed -r \
		-e 's:[^a-zA-Z0-9.-]+:-:g' \
		-e 's:-+:-:g' \
		-e 's:^-|-$::g' \
		-e 's:^v([0-9]):\1:g'
}

TAGS=""

if [ "$EVENT_NAME" == "pull_request" ]; then
	if [ -z "$PR_ID" ]; then
		echo "error: pr id not included in event, can't continue"
		exit 1
	fi

	TAGS+="pr-${PR_ID},"
elif [ "$EVENT_NAME" == "push" ]; then
	if [ "$GIT_REF_TYPE" == "branch" ]; then
		# sanitize and validate the branch name.
		if grep -qE '^v?[0-9]+' <<<"$GIT_REF_NAME"; then
			echo "error: invalid branch name, might overwrite semver"
			exit 1
		fi

		TAGS+="$(sanitize <<<"$GIT_REF_NAME"),"
	else
		# assume tag

		LATEST=$(svu current --strip-prefix --no-metadata --tag-mode=all-branches)

		# check if requested tag is semver compliant (at least somewhat).
		read -r MAJOR MINOR PATCH SUFFIX <<<"$(sed -r 's:^v?([0-9]+)\.([0-9]+)\.([0-9]+)(.*)$:\1 \2 \3 \4:g' <<<"$GIT_REF_NAME")"

		if [ -n "$SUFFIX" ] || [ -z "$MINOR" ]; then
			# assume semver with alpha/rc/etc (and maybe build metadata)
			# OR tag isn't semver.
			TAGS+="tag-$(sanitize <<<"$GIT_REF_NAME"),"
		elif [ -n "$MAJOR" ] && [ -n "$MINOR" ] && [ -n "$PATCH" ]; then
			TAGS+="${MAJOR}.${MINOR}.${PATCH},${MAJOR}.${MINOR},"
			TAGS+="${MAJOR}.${MINOR}.${PATCH}-$(date +"%Y%m%d-${GIT_SHA:0:7}"),"

			# check to see if the new tag is the latest version, to apply v1 and v1.2.
			if [ "$LATEST" == "${MAJOR}.${MINOR}.${PATCH}" ]; then
				TAGS+="${MAJOR},latest,"
			fi
		else
			echo "error: issue parsing semver"
			exit 1
		fi
	fi
else
	echo "error: unknown event type '${EVENT_NAME}'"
	exit 1
fi

echo "::set-output name=tags::$(sed -r 's:,+$::g' <<<"$TAGS")"

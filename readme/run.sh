#!/bin/bash -eu
# shellcheck disable=SC2155

# TODO: this could probably be a simple go cli tool, rather than a bash script.
# or maybe its own action?

P2_VERSION="r16"

set -o pipefail
export BASE=$(readlink -f "$(dirname "$0")/..")

FILEPATH="${1:?usage: $0 <filepath>}"
export README=$(cat "$FILEPATH")

export GITHUB_EVENT_PATH="${GITHUB_EVENT_PATH:-${BASE}/readme/example-event.json}"

function setup {
	if which p2 > /dev/null 2>&1; then
		return
	fi

	wget -q -O /usr/local/bin/p2 "https://github.com/wrouesnel/p2cli/releases/download/${P2_VERSION}/p2-linux-x86_64"
	chmod +x /usr/local/bin/p2
}

function read_field {
	FIELD="$1"
	sed -rn '/<!--\s+?template:define:'"$FIELD"'/,/-->/{ /<!--/! { /-->/! p } }' <<< "$README"
}

# usage: stdin | update_field "key" "my-content" | stdout
function update_field {
	FIELD="$1"
	CONTENT=$(envsubst <<< "$2")

	if ! grep -qE "template:begin:${FIELD}" <<< "$README"; then
		echo -e "$README"
		return
	else /bin/true; fi

	CONTENT="<!-- do not edit anything in this \"template\" block, its auto-generated -->\n$CONTENT"

	awk \
		-v CONTENT="$CONTENT" \
		-v FIELD="$FIELD" \
		-v RS="template:begin:${FIELD} .* template:end:${FIELD}" \
		-v ORS= \
		'1;NR==1{print "template:begin:" FIELD " -->\n" CONTENT "\n<!-- template:end:" FIELD}' <<< "$README"
}

function update_field_file {
	SECTION=$(GITHUB_TOKEN='' jq -r '.env |= env' <<< "$JSON" | p2 --format=json --template "${BASE}/readme/sections/$2")
	update_field "$1" "$SECTION"
}

function generate_metadata {
	# required data.
	gh api "/repos/${GITHUB_REPOSITORY}" > /tmp/repository.json
	gh api "/repos/${GITHUB_REPOSITORY}/actions/workflows" | jq -r '.workflows' > /tmp/workflows.json
	gh api "/repos/${GITHUB_REPOSITORY}/languages" > /tmp/languages.json

	if ! gh api "/repos/${GITHUB_REPOSITORY}/releases/latest" > /tmp/latest-release.json 2> /dev/null; then
		echo "{}" > /tmp/latest-release.json
	else /bin/true; fi

	gh api '/user/packages?package_type=container&visibility=public' 2> /dev/null | GITHUB_TOKEN='' jq '[
		.[] | select(.repository.full_name == env.GITHUB_REPOSITORY) | {
			name: .name,
			repo: .repository.name,
			user: .owner.login,
			visibility: .visibility,
			url: .html_url,
		}
	]' > /tmp/ghcr.json

	# get the tags for each ghcr container.
	while read -r PKG; do
		if [ -z "$PKG" ]; then
			continue
		fi

		export PKG
		export TAGS=$(
			gh api "/user/packages/container/${PKG}/versions?per_page=50&state=active" \
				| jq -r '.[].metadata.container.tags[]' \
				| grep -Ei "^master|^main|^latest|^v?[0-9]+\.[0-9]+\.[0-9]+$" \
				| jq -sRr 'split("\n") | map(select(. != ""))'
		)
		jq -r '.[] | select(.name == env.PKG) | .tags = (env.TAGS | fromjson)' /tmp/ghcr.json
	done <<< "$(jq -r '.[].name' /tmp/ghcr.json)" | jq -sr '.' > /tmp/ghcr-tags.json

	# any settings that might be in the readme.
	read_field "options" > /tmp/options.json

	# generate a single object to pass into templates.
	export JSON=$(
		{
			cat /tmp/repository.json
			cat /tmp/workflows.json
			cat /tmp/languages.json
			cat /tmp/ghcr-tags.json
			cat /tmp/latest-release.json
			cat /tmp/options.json
		} | jq -s '{
			repo: .[0],
			workflows: .[1],
			languages: .[2],
			language_count: (.[2] | length),
			ghcr: .[3],
			latest_release: .[4],
			options: (.[5] // {}),
		}'
	)
	echo "$JSON"
}

function generate_toc {
	# use iconv to convert utf-8 to ascii, and remove any non-ascii characters (like emojis).
	TOC=$(
		gh api \
			-X POST \
			-H 'Content-Type: text/x-markdown' \
			--input - /markdown/raw <<< "$README" \
			| sed -rn 's:.*user-content.* href="(#[^"]+)"[^>]+?>\s+?(.*)</h([0-9]+)>.*:\3 \1 \2:p' \
			| sed -r 's:<[^>]+>.*</[^>]+> +?::g' \
			| sed -r 's:<[^>]+> +?::g' \
			| grep -v 'table-of-contents' \
			| iconv -c -f utf-8 -t ascii \
			| sed -r 's: +: :g'
	)

	echo -e "## :link: Table of Contents\n"

	while read -r INDENT ID NAME; do
		INDENT=$(($((INDENT - 1)) * 2))
		printf "%${INDENT}s- [%s](%s)\n" '' "$NAME" "$ID"
	done <<< "$TOC"
}

function generate {
	# misc things that may be used.
	if [ -f go.mod ]; then
		export GO_MODULE=$(sed -rn 's:^module (.*)$:\1:p' go.mod)
		README=$(update_field_file "goget" "goget.md")
	fi

	README=$(update_field_file "header" "header.md")
	README=$(update_field_file "ghcr" "ghcr.md")

	if [ -f ".github/SUPPORT.md" ]; then
		README=$(update_field_file "support" "support.md")
	fi

	if [ -f ".github/CONTRIBUTING.md" ]; then
		README=$(update_field_file "contributing" "contributing.md")
	fi

	if [ -f "LICENSE" ]; then
		export LICENSE=$(cat LICENSE)
		README=$(update_field_file "license" "license.md")
	fi

	README=$(update_field "toc" "$(generate_toc)")

	echo -e "$README" > "$FILEPATH"
}

setup
generate_metadata
generate

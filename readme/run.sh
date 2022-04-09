#!/bin/bash -eu
# shellcheck disable=SC2155

# TODO: this could probably be a simple go cli tool, rather than a bash script.
# or maybe its own action?

set -o pipefail
export BASE=$(readlink -f "$(dirname "$0")/..")

FILEPATH="${1:?usage: $0 <filepath>}"
export README=$(cat "$FILEPATH")

export GITHUB_EVENT_PATH="${GITHUB_EVENT_PATH:-${BASE}/readme/example-event.json}"

function setup {
	if which p2 > /dev/null 2>&1; then
		return
	fi

	VERSION="r11"
	wget -q -O /usr/local/bin/p2 "https://github.com/wrouesnel/p2cli/releases/download/${VERSION}/p2-linux-x86_64"
	chmod +x /usr/local/bin/p2
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

	gh api '/user/packages?package_type=container&visibility=public' | GITHUB_TOKEN='' jq '[
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
		export PKG
		export TAGS=$(
			gh api "/user/packages/container/${PKG}/versions?per_page=50&state=active" \
				| jq -r '.[].metadata.container.tags[]' \
				| grep -Ei "^master|^main|^v?[0-9]+\.[0-9]+\.[0-9]+$" \
				| jq -sRr 'split("\n") | map(select(. != ""))'
		)
		jq -r '.[] | select(.name == env.PKG) | .tags = (env.TAGS | fromjson)' /tmp/ghcr.json
	done <<< "$(jq -r '.[].name' /tmp/ghcr.json)" | jq -sr '.' > /tmp/ghcr-tags.json

	# generate a single object to pass into templates.
	export JSON=$(
		{
			cat /tmp/repository.json
			cat /tmp/workflows.json
			cat /tmp/languages.json
			cat /tmp/ghcr-tags.json
			cat /tmp/latest-release.json
		} | jq -s '{
			repo: .[0],
			workflows: .[1],
			languages: .[2],
			language_count: (.[2] | length),
			ghcr: .[3],
			latest_release: .[4],
		}'
	)
	echo "$JSON"
}

function generate_toc {
	declare -a TOC
	declare -A IDLIST
	CODE_BLOCK=0
	CODE_BLOCK_REGEX='^```'
	HEADING_REGEX='^#{1,}'

	while read -r LINE; do
		# parse any code blocks.
		if [[ ${LINE} =~ $CODE_BLOCK_REGEX ]]; then
			# ignore until we see code block ending.
			CODE_BLOCK=$((CODE_BLOCK + 1))
			if [[ ${CODE_BLOCK} -eq 2 ]]; then
				# closing code block.
				CODE_BLOCK=0
			fi
			continue
		fi

		# normal lines.
		if [[ ${CODE_BLOCK} == 0 ]]; then
			# if we see a heading, we save it to the TOC array.
			if [[ ${LINE} =~ ${HEADING_REGEX} ]]; then
				TOC+=("$LINE")
			fi
		fi
	done <<< "$(grep -v 'Table of Contents' <<< "$README")"

	echo -e "## :link: Table of Contents\n"
	for LINE in "${TOC[@]}"; do
		# strip links, if they exist in the heading.
		LINE="$(sed -r 's:^([^\[]+)\[(.+)\].*:\1\2:g' <<< "$LINE")"

		# strip any emojis if they exist.
		LINK="$(sed -r 's/\s+?:([^:]+):\s+?/ \1 /g' <<< "$LINE")"
		LINE="$(sed -r 's/\s+?:[^:]+:\s+?/ /g' <<< "$LINE")"

		# special characters (besides '-') in page links in markdown are deleted
		# and spaces are converted to dashes.
		LINK=$(tr -dc "[:alnum:] _-" <<< "$LINK")
		LINK="${LINK/ /}"
		LINK="${LINK// /-}"
		LINK="${LINK,,}"
		LINK=$(tr -s "-" <<< "$LINK")

		if [ "${IDLIST[$LINK]:=0}" == 0 ]; then
			IDLIST[$LINK]=0
		else
			IDLIST[$LINK]=$((IDLIST[$LINK] + 1))
			LINK+="-${IDLIST[$LINK]}"
		fi

		LENGTH=$(tr -cd '#' <<< "$LINE" | wc -c)
		LENGTH=$(($((LENGTH - 1)) * 2))

		printf "%${LENGTH}s- [%s](#%s)\n" '' "${LINE#\#* }" "$LINK"
	done
}

function generate {
	# misc things that may be used.
	if [ -f go.mod ]; then
		export GO_MODULE=$(sed -rn 's:^module (.*)$:\1:p' go.mod)
		README=$(update_field_file "goget" "goget.md")
	fi

	README=$(update_field_file "header" "header.md")
	README=$(update_field_file "ghcr" "ghcr.md")

	if [ -f "SUPPORT.md" ]; then
		README=$(update_field_file "support" "support.md")
	fi

	if [ -f "CONTRIBUTING.md" ]; then
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

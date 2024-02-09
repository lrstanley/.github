#!/bin/bash -eu
# shellcheck disable=SC2155,SC2005

# testing locally:
# export GITHUB_EVENT_NAME=push
# export GITHUB_REF_NAME=master
# export GITHUB_REF_TYPE=branch
# export GITHUB_REPOSITORY_OWNER=lrstanley
# export GITHUB_REPOSITORY=lrstanley/vault-unseal
# export INPUT_ARCHIVES=false
# export INPUT_DRAFT=false
# export INPUT_HAS_GHCR=true
# export INPUT_IMAGE_NAME=vault-unseal

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

VERSION_GOREL="1.24.0"
FLAGS=()

function setup_config {
	export HEADER="${BASE}/goreleaser/config/header-tmpl.md"
	export FOOTER="${BASE}/goreleaser/config/footer-tmpl.md"
	export CONFIG="${BASE}/goreleaser/config/goreleaser.yml"
	if [ -f ".goreleaser.yml" ]; then
		CONFIG=".goreleaser.yml"
	fi

	echo "using config file: ${CONFIG}"

	# copy everything, so we're not operating on things locally.
	cp -v "$HEADER" /tmp/header.md && HEADER=/tmp/header.md
	cp -v "$FOOTER" /tmp/footer.md && FOOTER=/tmp/footer.md
	cp -v "$CONFIG" /tmp/goreleaser.yml && CONFIG=/tmp/goreleaser.yml
}

function install_goreleaser {
	if command -v goreleaser > /dev/null 2>&1; then
		return
	fi

	echo "installing goreleaser '${VERSION_GOREL}'"
	curl -sSL \
		"https://github.com/goreleaser/goreleaser/releases/download/v${VERSION_GOREL}/goreleaser_Linux_x86_64.tar.gz" \
		| tar -C /usr/local/bin/ -xzvf- goreleaser

	chmod +x /usr/local/bin/goreleaser
}

function envrepl {
	envsubst < "$1" > /tmp/out
	cat < /tmp/out > "$1"
}

function yaml {
	(
		set -x
		yq -i "$1" "$CONFIG"
	)
}

# snippet <enable|disable> <snippet> <file>
function snippet {
	if [ "$1" == "enable" ]; then
		sed -ri "/~(START|END)_${2}~/d" "$3"
	else
		sed -ri "/~START_${2}~/,/~END_${2}~/d" "$3"
	fi
}

function make_has {
	if [ ! -f "Makefile" ]; then
		return 1
	fi

	grep -qE "^${1}:" Makefile && return 0 || return 1
}

function inject_pre {
	if [ -f ".github/ci-config.yml" ]; then
		yaml '. *n (load(".github/ci-config.yml") | .goreleaser.pre // {})' # only new
	fi
}

function inject_post {
	if [ -f ".github/ci-config.yml" ]; then
		yaml '. * (load(".github/ci-config.yml") | .goreleaser.post // {})' # only and replace existing.
	fi
}

function add_before_hook {
	yaml '.before.hooks += ["'"$1"'"]'
}

function inject_hooks {
	# prefer the more global scope prepare vs just the go one (which might be different for linting).
	if make_has prepare; then
		add_before_hook "make prepare"
	elif make_has go-prepare; then
		add_before_hook "make go-prepare"
	fi
}

function inject_builds {
	if [ -f ".github/ci-config.yml" ]; then
		# custom build array.
		yaml '.builds = ([(load(".github/ci-config.yml") | .goreleaser.builds // {})] | flatten)'
	fi

	# merge any fields we have defined that each build doesn't.
	yaml '.builds = [(.builds[] *n load(env(BASE) + "/goreleaser/config/build-fields.yml"))]'
}

function inject_required {
	if [ "$GITHUB_REF_TYPE" == "tag" ]; then
		yaml '.release.prerelease = "auto"'

		if grep -qEi "\-(alpha)" <<< "$GITHUB_REF"; then
			yaml ".changelog.skip = true"
		fi
	else
		yaml '.release.disable = true'
		FLAGS+=(--snapshot)
	fi

	yaml ".release.draft = ${INPUT_DRAFT}"
	yaml '.release.mode = "replace"'

	if [ "$INPUT_ARCHIVES" != "true" ]; then
		yaml 'del(.archives[] | select(.id == "archives"))'
	fi

	envrepl "$CONFIG"
}

function generate_headers {
	if [ "$INPUT_HAS_GHCR" == "true" ]; then
		snippet enable GHCR "$FOOTER"
	else
		snippet disable GHCR "$FOOTER"
	fi

	if grep -qEi "\-(rc)" <<< "$GITHUB_REF"; then
		snippet enable PRERELEASE "$HEADER"
	else
		snippet disable PRERELEASE "$HEADER"
	fi

	# vars needed by header/footer/etc.
	export GOBUILDINFO="$(go version)"

	envrepl "$HEADER"
	envrepl "$FOOTER"
}

function main {
	for fn in \
		install_goreleaser \
		setup_config \
		inject_pre \
		inject_hooks \
		inject_required \
		inject_builds \
		inject_post \
		generate_headers; do

		echo "running '${fn}'"
		"$fn"
	done

	set -x
	cat "$CONFIG"
	cat "$HEADER"
	cat "$FOOTER"

	if [ "$GITHUB_REF_TYPE" == "tag" ]; then
		export GORELEASER_CURRENT_TAG="$GITHUB_REF_NAME"

		if ! grep -qEi "\-(rc|alpha)" <<< "$GITHUB_REF_NAME"; then
			PREV=$(git tag --sort=-version:refname | grep -vEi "\-(rc|alpha)" | grep -FiA1 "$GITHUB_REF_NAME" | tail -1)
			if [ "$PREV" != "$GITHUB_REF_NAME" ]; then
				export GORELEASER_PREVIOUS_TAG="$PREV"
			else
				export GORELEASER_PREVIOUS_TAG="$(git rev-list --max-parents=0 HEAD | cut -c -7)"
			fi
		fi
	fi

	set -x
	goreleaser release \
		--config "$CONFIG" \
		--rm-dist \
		--skip-validate \
		--timeout "10m" \
		--parallelism 5 \
		--release-header-tmpl "$HEADER" \
		--release-footer-tmpl "$FOOTER" "${FLAGS[@]}"

	tree dist/
}

main

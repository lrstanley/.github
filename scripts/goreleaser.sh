#!/bin/bash -eu
# shellcheck disable=SC2155,SC2005

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

VERSION_GOREL="1.7.0"
FLAGS=()

export HEADER="${BASE}/configs/goreleaser/header-tmpl.md"
export FOOTER="${BASE}/configs/goreleaser/footer-tmpl.md"
export CONFIG="${BASE}/configs/goreleaser/goreleaser.yml"
if [ -f ".goreleaser.yml" ]; then
	CONFIG=".goreleaser.yml"
fi

echo "using config file: ${CONFIG}"

function install_goreleaser {
	echo "installing goreleaser '${VERSION_GOREL}'"
	curl -sSL \
		"https://github.com/goreleaser/goreleaser/releases/download/v${VERSION_GOREL}/goreleaser_Linux_x86_64.tar.gz" \
		| tar -C /usr/local/bin/ -xzvf- goreleaser

	chmod +x /usr/local/bin/goreleaser
}

function envrepl {
	envsubst <"$1" >/tmp/out
	cat </tmp/out >"$1"
}

function yaml {
	(
		set -x
		yq -i "$1" "$CONFIG"
	)
}

function make_has {
	if [ ! -f "Makefile" ]; then
		return 1
	fi

	grep -qE "^${1}:" Makefile && return 0 || return 1
}

function inject_pre {
	if [ -f ".goreleaser.pre.yml" ]; then
		yaml '. *n= load(".goreleaser.pre.yml")'
	fi
}

function inject_post {
	if [ -f ".goreleaser.post.yml" ]; then
		yaml '. *= load(".goreleaser.post.yml")'
	fi
}

function add_before_hook {
	yaml '.before.hooks += ["'"$1"'"]'
}

function inject_hooks {
	if make_has fetch; then
		add_before_hook "make fetch"
	else
		add_before_hook "go mod download"
		add_before_hook "go mod tidy"
	fi

	if make_has clean; then
		add_before_hook "make clean"
	fi

	if make_has generate; then
		add_before_hook "make generate"
	else
		add_before_hook "go generate ./..."
	fi
}

function inject_builds {
	if [ -f ".builds.yml" ]; then
		yaml '.builds = ([load(".builds.yml")] | flatten)'
	fi

	yaml '.builds = [(.builds[] *n load(env(BASE) + "/configs/goreleaser/build-fields.yml"))]'
}

function inject_required {
	if [ "$GITHUB_EVENT_NAME" == "tag" ]; then
		yaml '.release.prerelease = "auto"'

		if grep -qEi "\-(alpha)" <<<"$GITHUB_REF"; then
			yaml ".changelog.skip = true"
		fi
	elif [ "$GITHUB_EVENT_NAME" == "push" ]; then
		yaml '.release.disable = true'
		FLAGS+=(--snapshot)
	elif [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
		yaml '.release.disable = true'
		FLAGS+=(--snapshot)
	else
		echo "unknown event type: $GITHUB_EVENT_NAME"
		exit 1
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
		sed -ri '/~(START|END)_GHCR~/d' "$FOOTER"
	else
		sed -ri '/~START_GHCR~/,/~END_GHCR~/d' "$FOOTER"
	fi

	# vars needed by header/footer/etc.
	export GOBUILDINFO="$(go version)"
	export CONTRIBUTING="https://github.com/${GITHUB_REPOSITORY_OWNER}/.github/blob/master/CONTRIBUTING.md"
	export SUPPORT="https://github.com/${GITHUB_REPOSITORY_OWNER}/.github/blob/master/SUPPORT.md"

	# if repo already has a doc for this, use it instead.
	if [ -f "CONTRIBUTING.md" ]; then
		export CONTRIBUTING="https://github.com/${GITHUB_REPOSITORY}/blob/${GITHUB_REF_NAME}/CONTRIBUTING.md"
	fi

	# if repo already has a doc for this, use it instead.
	if [ -f "SUPPORT.md" ]; then
		export SUPPORT="https://github.com/${GITHUB_REPOSITORY}/blob/${GITHUB_REF_NAME}/SUPPORT.md"
	fi

	envrepl "$HEADER"
	envrepl "$FOOTER"
}

function main {
	for fn in \
		install_goreleaser \
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

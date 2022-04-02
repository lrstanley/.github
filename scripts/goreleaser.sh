#!/bin/bash -eux
# shellcheck disable=SC2155,SC2005

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

VERSION_GOREL="1.7.0"

curl -sSL \
	"https://github.com/goreleaser/goreleaser/releases/download/v${VERSION_GOREL}/goreleaser_Linux_x86_64.tar.gz" \
	| tar -C /usr/local/bin/ -xzvf- goreleaser

chmod +x /usr/local/bin/goreleaser

FLAGS=()

CONFIG="${BASE}/configs/goreleaser/goreleaser.yml"
if [ -f ".goreleaser.yml" ]; then
	CONFIG=".goreleaser.yml"
fi

function envrepl {
	set +x
	envsubst <"$1" >/tmp/out
	cat </tmp/out >"$1"
	set -x
}

function yaml {
	yq -i "$1" "$CONFIG"
}

if [ -f ".goreleaser.pre.yml" ]; then
	yaml '. *= load(".goreleaser.pre.yml")'
fi

yaml '.builds = [(.builds[] *+ load(env(BASE) + "/configs/goreleaser/build-fields.yml"))]'

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

if [ -f "Makefile" ]; then
	if grep -qE "^fetch:" Makefile; then
		yaml '.before.hooks += ["make fetch"]'
	else
		yaml '.before.hooks += ["go mod download"]'
		yaml '.before.hooks += ["go mod tidy"]'
	fi

	if grep -qE "^clean:" Makefile; then
		yaml '.before.hooks += ["make clean"]'
	fi

	if grep -qE "^generate:" Makefile; then
		yaml '.before.hooks += ["make generate"]'
	else
		yaml '.before.hooks += ["go generate ./..."]'
	fi
fi

if [ "$INPUT_ARCHIVES" != "true" ]; then
	yaml 'del(.archives[] | select(.id == "archives"))'
fi

if [ "$INPUT_HAS_GHCR" == "true" ]; then
	sed -ri '/~(START|END)_GHCR~/d' "${BASE}/configs/goreleaser/footer-tmpl.md"
else
	sed -ri '/~START_GHCR~/,/~END_GHCR~/d' "${BASE}/configs/goreleaser/footer-tmpl.md"
fi

# vars needed by header/footer/etc.
export GOBUILDINFO="$(go version)"
export CONTRIBUTING="https://github.com/lrstanley/.github/blob/master/CONTRIBUTING.md"
export SUPPORT="https://github.com/lrstanley/.github/blob/master/SUPPORT.md"

# if repo already has a doc for this, use it instead.
if [ -f "CONTRIBUTING.md" ]; then
	export CONTRIBUTING="https://github.com/${GITHUB_REPOSITORY}/blob/${GITHUB_REF_NAME}/CONTRIBUTING.md"
fi

# if repo already has a doc for this, use it instead.
if [ -f "SUPPORT.md" ]; then
	export SUPPORT="https://github.com/${GITHUB_REPOSITORY}/blob/${GITHUB_REF_NAME}/SUPPORT.md"
fi

envrepl "$CONFIG"
envrepl "${BASE}/configs/goreleaser/header-tmpl.md"
envrepl "${BASE}/configs/goreleaser/footer-tmpl.md"

if [ -f ".goreleaser.post.yml" ]; then
	yaml '. *= load(".goreleaser.post.yml")'
fi

cat "$CONFIG" && sleep 1
cat "${BASE}/configs/goreleaser/header-tmpl.md" && sleep 1
cat "${BASE}/configs/goreleaser/footer-tmpl.md" && sleep 1

goreleaser release \
	--config "$CONFIG" \
	--rm-dist \
	--skip-validate \
	--timeout "10m" \
	--parallelism 5 \
	--release-header-tmpl "${BASE}/configs/goreleaser/header-tmpl.md" \
	--release-footer-tmpl "${BASE}/configs/goreleaser/footer-tmpl.md" "${FLAGS[@]}"

tree dist/

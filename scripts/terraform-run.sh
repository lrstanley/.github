#!/bin/bash -eu
#shellcheck disable=SC2155

: "$TF_API_TOKEN"
: "$TF_ORG"
: "$TF_WORKSPACE"
: "$GITHUB_ACTION"

set -o pipefail
export BASE="$(readlink -f "$(dirname "$0")/..")"

function fetch_workspace {
	curl -sS \
		--header "Authorization: Bearer ${TF_API_TOKEN}" \
		--header "Content-Type: application/vnd.api+json" \
		--request GET "https://app.terraform.io/api/v2/organizations/${TF_ORG}/workspaces" \
		| jq '.data[] | select(.attributes.name == env.TF_WORKSPACE)' > workspace.json

	export TF_WORKSPACE_ID="$(jq -r '.id' workspace.json)"
}

function start_run {
	cat << EOF > payload.json
	{
		"data": {
		"attributes": {
			"message": "github-actions-trigger: ${GITHUB_ACTION}"
		},
		"type":"runs",
			"relationships": {
				"workspace": {
					"data": {
						"type": "workspaces",
						"id": "${TF_WORKSPACE_ID}"
					}
				}
			}
		}
	}
EOF

	curl -sS \
		--header "Authorization: Bearer ${TF_API_TOKEN}" \
		--header "Content-Type: application/vnd.api+json" \
		--request POST \
		--data @payload.json \
		https://app.terraform.io/api/v2/runs | jq '.'
}

fetch_workspace
start_run

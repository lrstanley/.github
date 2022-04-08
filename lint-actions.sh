#!/bin/bash -eu

find "$PWD" -type f -ipath "**/.github/workflows/*.yml" | while read -r WF; do
	HAS_GLOBAL_PERMISSIONS=$(yq '. | has("permissions")' "$WF")

	if [ "$HAS_GLOBAL_PERMISSIONS" == "true" ]; then
		echo -e "\e[1;32m==> '${WF}' has global permissions\e[0m"
		continue
	fi

	JOBS=$(yq '.jobs | keys | .[]' "$WF")

	for JOB in $JOBS; do
		export JOB

		if [ "$(yq '.jobs[env(JOB)] | has("permissions")' "$WF")" == "true" ]; then
			echo -e "\e[1;32m==> '${WF}' >> '${JOB}' has job permissions\e[0m"
			continue
		else
			echo >&2 -e "\e[1;31m!!> '${WF}' >> '${JOB}' doesn't have job permissions (and no global permissions)\e[0m"
			exit 1
		fi
	done
done

echo -e "\e[1;32m==> SUCCESS\e[0m"

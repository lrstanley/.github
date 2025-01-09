#!/bin/bash -ex

export ISSUE_URL="/repos/${GITHUB_REPOSITORY}/issues"
export COMMENT="<!-- pr-commenter-id:${ID} -->
${COMMENT}"

# validate inputs.
if ! grep -qE '^[a-zA-Z0-9_-]{3,30}$' <<< "$ID"; then
	echo "Invalid ID: $ID"
	exit 1
fi

if [ "$ACTION" != "delete" ]; then
	if [ -z "$COMMENT" ]; then
		echo "Comment is required when action is not 'delete'"
		exit 1
	fi
fi

# <!-- pr-commenter-id:this-is-a-test -->
function get_id_comments() {
	gh api "${ISSUE_URL}/${PR_ID}/comments?page=1&per_page=100" \
		| jq -r '.[] | select(.body | test(".*<!-- pr-commenter-id:" + env.ID + " -->.*")) | .id'
}

case "$ACTION" in
	add)
		if [ "$ALWAYS_ADD_COMMENT" == "true" ]; then
			# add comment.
			echo "$COMMENT" | gh api --method POST "${ISSUE_URL}/${PR_ID}/comments" -F "body=@-"
			exit 0
		fi

		EXISTING_COMMENTS="$(get_id_comments)"
		COMMENT_COUNT="$(grep -cE "^[0-9]+$" <<< "$EXISTING_COMMENTS" || true)"

		# if > 1, delete all but the first.
		if [ "$COMMENT_COUNT" -gt 1 ]; then
			while read -r COMMENT_ID; do
				gh api --method DELETE "${ISSUE_URL}/comments/${COMMENT_ID}"
			done <<< "$(tail -n +2 <<< "$EXISTING_COMMENTS")"
		fi

		if [ "$COMMENT_COUNT" -gt 0 ]; then
			# update the first comment.
			echo "$COMMENT" | gh api --method PATCH "${ISSUE_URL}/comments/$(head -n 1 <<< "$EXISTING_COMMENTS")" -F "body=@-"
		else
			# add comment.
			echo "$COMMENT" | gh api --method POST "${ISSUE_URL}/${PR_ID}/comments" -F "body=@-"
		fi
		;;
	replace)
		# delete any existing comments.
		while read -r COMMENT_ID; do
			gh api --method DELETE "${ISSUE_URL}/comments/${COMMENT_ID}"
		done <<< "$(get_id_comments)"

		# add comment.
		echo "$COMMENT" | gh api --method POST "${ISSUE_URL}/${PR_ID}/comments" -F "body=@-"
		;;
	delete)
		# delete any existing comments.
		while read -r COMMENT_ID; do
			gh api --method DELETE "${ISSUE_URL}/comments/${COMMENT_ID}"
		done <<< "$(get_id_comments)"
		;;
	*)
		echo "Invalid action: $ACTION"
		exit 1
		;;
esac

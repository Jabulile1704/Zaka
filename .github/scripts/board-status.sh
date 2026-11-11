#!/usr/bin/env bash
#
# Puts an issue or pull request on the project board and sets its Status.
#
#   board-status.sh <number> "<Status name>"
#
# The column is looked up by name, so renaming or recreating the columns does
# not break this. Needs a token with the `project` scope in GH_TOKEN: the
# default GITHUB_TOKEN cannot write to a user-level project.
#
# One query and two mutations per call. The `gh project` subcommands do the
# same job at several times the rate-limit cost, which is how filing thirty
# issues once exhausted the hourly GraphQL quota.

set -euo pipefail

number="$1"
status="$2"
owner="${PROJECT_OWNER:-Jabulile1704}"
project="${PROJECT_NUMBER:-6}"
repo="${REPO:-Jabulile1704/Zaka}"

case "$status" in
  *[\"\\]*) echo "Status name may not contain quotes or backslashes" >&2; exit 1 ;;
esac

read -r project_id field_id option_id < <(gh api graphql \
  -f query='query($owner: String!, $number: Int!) {
    user(login: $owner) { projectV2(number: $number) {
      id
      field(name: "Status") { ... on ProjectV2SingleSelectField { id options { id name } } }
    } }
  }' -f owner="$owner" -F number="$project" \
  --jq ".data.user.projectV2 | \"\(.id) \(.field.id) \((.field.options[] | select(.name == \"$status\") | .id) // \"\")\"")

if [ -z "${option_id:-}" ]; then
  echo "No status named '$status' on the board" >&2
  exit 1
fi

content_id=$(gh api "repos/$repo/issues/$number" --jq '.node_id')

item_id=$(gh api graphql \
  -f query='mutation($project: ID!, $content: ID!) {
    addProjectV2ItemById(input: {projectId: $project, contentId: $content}) { item { id } }
  }' -f project="$project_id" -f content="$content_id" \
  --jq '.data.addProjectV2ItemById.item.id')

gh api graphql \
  -f query='mutation($project: ID!, $item: ID!, $field: ID!, $option: String!) {
    updateProjectV2ItemFieldValue(input: {
      projectId: $project, itemId: $item, fieldId: $field,
      value: {singleSelectOptionId: $option}
    }) { projectV2Item { id } }
  }' -f project="$project_id" -f item="$item_id" -f field="$field_id" -f option="$option_id" \
  > /dev/null

echo "#$number -> $status"

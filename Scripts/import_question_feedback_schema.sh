#!/usr/bin/env bash
# Imports CloudKit/QuestionFeedback.ckdb into the Development environment.
# Production: use CloudKit Console → Deploy Schema to Production (cktool cannot import to production).
# Usage: ./Scripts/import_question_feedback_schema.sh
# Prerequisite: ./Scripts/cktool_save_management_token.sh (once per machine)
# See docs/cloudkit-question-feedback-schema.md

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEMA_FILE="$ROOT/CloudKit/QuestionFeedback.ckdb"
TEAM_ID="SZQ626NP5U"
CONTAINER_ID="iCloud.com.gizatech.Leben-in-Deutschland"
ENVIRONMENT="development"

if [[ "${1:-}" == "production" ]]; then
  echo "cktool cannot import schema into Production." >&2
  echo "Use CloudKit Console → Deploy Schema to Production instead." >&2
  echo "See docs/cloudkit-question-feedback-schema.md#production-deploy-after-testing" >&2
  exit 1
fi

if [[ ! -f "$SCHEMA_FILE" ]]; then
  echo "Schema file not found: $SCHEMA_FILE" >&2
  exit 1
fi

on_auth_failure() {
  echo "" >&2
  echo "CloudKit authentication failed." >&2
  echo "Fix: run ./Scripts/cktool_save_management_token.sh" >&2
  echo "  • Use token type: management (not user)" >&2
  echo "  • Generate a new token in the browser if the old one expired" >&2
  echo "Alternative: create the schema manually in CloudKit Console (Option B in docs/cloudkit-question-feedback-schema.md)" >&2
  exit 1
}

echo "Validating schema against $CONTAINER_ID ($ENVIRONMENT)..."
if ! xcrun cktool validate-schema \
  --team-id "$TEAM_ID" \
  --container-id "$CONTAINER_ID" \
  --environment "$ENVIRONMENT" \
  --file "$SCHEMA_FILE"; then
  on_auth_failure
fi

echo "Importing QuestionFeedback record type..."
if ! xcrun cktool import-schema \
  --team-id "$TEAM_ID" \
  --container-id "$CONTAINER_ID" \
  --environment "$ENVIRONMENT" \
  --file "$SCHEMA_FILE"; then
  on_auth_failure
fi

ENV_LABEL="Development"
echo "Done. Open CloudKit Console → $ENV_LABEL → Schema → QuestionFeedback to verify."

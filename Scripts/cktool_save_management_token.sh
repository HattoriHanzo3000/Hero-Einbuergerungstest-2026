#!/usr/bin/env bash
# Saves a fresh CloudKit *management* token for cktool (schema import/export).
# Interactive: opens browser, paste token back into Terminal.
# See docs/cloudkit-question-feedback-schema.md

set -euo pipefail

echo "Removing any stale cktool tokens..."
xcrun cktool remove-token --type management --force 2>/dev/null || true
xcrun cktool remove-token --type user --force 2>/dev/null || true

echo ""
echo "Opening CloudKit token flow..."
echo "IMPORTANT:"
echo "  • Token type: management (this script passes --type management)"
echo "  • Choose: generate a NEW token in the browser"
echo "  • Sign in with your Apple Developer account (team SZQ626NP5U)"
echo "  • Copy the MANAGEMENT token and paste it when Terminal prompts"
echo ""

xcrun cktool save-token --type management --force

echo ""
echo "Token saved. Next run:"
echo "  ./Scripts/import_question_feedback_schema.sh"

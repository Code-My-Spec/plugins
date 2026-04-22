#!/usr/bin/env bash
#
# Logs Claude Code skill invocations to ~/.claude/skill_invocations.jsonl.
# Installed by /daily-plan's bootstrap step, on user consent.
#
# Wires in via ~/.claude/settings.json as both a PreToolUse and UserPromptSubmit
# hook. It reads the hook event JSON from stdin and writes a JSONL line when
# it sees either:
#   - A Read tool call against a path ending in /SKILL.md (skill invoked)
#   - A user prompt starting with /<slash-command> (slash skill invoked)
#
# Never fails the parent event — always exits 0. If jq is missing, silently
# does nothing so the hook doesn't break the session.

set -u

LOG_FILE="${HOME}/.claude/skill_invocations.jsonl"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

# If jq isn't available, bail silently.
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

input="$(cat)"

# Defensive: if stdin was empty or not JSON, exit cleanly.
if [ -z "$input" ]; then
  exit 0
fi

hook_event="$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null || true)"
if [ -z "$hook_event" ]; then
  exit 0
fi

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)"

log_line() {
  # $1 = JSON object string — append to log
  printf '%s\n' "$1" >> "$LOG_FILE"
}

case "$hook_event" in
  PreToolUse)
    tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
    if [ "$tool_name" = "Read" ]; then
      file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
      case "$file_path" in
        */SKILL.md)
          # Derive skill name = parent directory name
          skill_dir="$(dirname "$file_path")"
          skill_name="$(basename "$skill_dir")"
          log_line "$(jq -nc \
            --arg ts "$ts" \
            --arg skill "$skill_name" \
            --arg path "$file_path" \
            --arg cwd "$cwd" \
            '{ts: $ts, event: "skill_read", skill: $skill, path: $path, cwd: $cwd}')"
          ;;
      esac
    fi
    ;;
  UserPromptSubmit)
    prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)"
    if [ -n "$prompt" ]; then
      # Match a leading slash command: /name or /plugin:name, allowing hyphens, underscores, digits
      # Only consider the first token, and only if the line begins with /
      first_line="$(printf '%s' "$prompt" | head -n1)"
      cmd="$(printf '%s' "$first_line" | awk '{print $1}')"
      case "$cmd" in
        /[A-Za-z]*)
          # Strip leading slash for cleaner logging
          cmd_name="${cmd#/}"
          log_line "$(jq -nc \
            --arg ts "$ts" \
            --arg cmd "$cmd_name" \
            --arg cwd "$cwd" \
            '{ts: $ts, event: "slash_command", command: $cmd, cwd: $cwd}')"
          ;;
      esac
    fi
    ;;
esac

exit 0

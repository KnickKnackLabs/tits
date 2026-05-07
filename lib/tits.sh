#!/usr/bin/env bash

# Shared helpers for tits tasks. This file self-locates; do not use
# MISE_CONFIG_ROOT here because tests may source it directly from an agent
# shell whose ambient MISE_CONFIG_ROOT points elsewhere.
TITS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TITS_REPO_DIR="$(cd "$TITS_LIB_DIR/.." && pwd)"
TITS_TEMPLATE_HOME="$TITS_REPO_DIR/templates/home"

say() { printf '%s\n' "$*"; }
err() { printf 'Error: %s\n' "$*" >&2; }

validate_agent() {
  local agent="$1"
  if [ -z "$agent" ]; then
    err "--agent is required"
    return 1
  fi

  case "$agent" in
    *[!a-z0-9-]* | -* | *-)
      err "agent must use lowercase letters, numbers, and internal hyphens only"
      return 1
      ;;
  esac
}

agent_upper_secret() {
  printf '%s' "$1" | tr '[:lower:]-' '[:upper:]_'
}

resolve_home_path() {
  local path="$1"
  if [ -z "$path" ]; then
    err "--home is required"
    return 1
  fi

  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *)  printf '%s/%s\n' "${CALLER_PWD:-$PWD}" "$path" ;;
  esac
}

render_template() {
  local src="$1"
  local dest="$2"
  local agent="$3"
  local agent_upper="$4"

  mkdir -p "$(dirname "$dest")"
  sed \
    -e "s/{{AGENT}}/$agent/g" \
    -e "s/{{AGENT_UPPER}}/$agent_upper/g" \
    "$src" > "$dest"
}

install_template_file() {
  local src="$1"
  local dest="$2"
  local agent="$3"
  local agent_upper="$4"
  local rel="${dest#"$TARGET_HOME"/}"

  if [ -e "$dest" ]; then
    say "keep: $rel"
    return 0
  fi

  render_template "$src" "$dest" "$agent" "$agent_upper"

  case "$rel" in
    .mise/tasks/*)
      chmod +x "$dest"
      ;;
  esac

  say "create: $rel"
}

install_home_templates() {
  local agent="$1"
  local agent_upper="$2"
  local src rel dest

  find "$TITS_TEMPLATE_HOME" -type f | sort | while IFS= read -r src; do
    rel="${src#"$TITS_TEMPLATE_HOME"/}"
    case "$rel" in
      *.tmpl) dest="$TARGET_HOME/${rel%.tmpl}" ;;
      *)      dest="$TARGET_HOME/$rel" ;;
    esac
    install_template_file "$src" "$dest" "$agent" "$agent_upper"
  done
}

required_files() {
  cat <<'EOF_REQ'
CLAUDE.md
notes/Status.md
mise.toml
.mise/tasks/welcome
.mise/tasks/self
.mise/tasks/agent/list
.mise/tasks/agent/identity
.mise/tasks/agent/prepare
.mise/tasks/human
.github/workflows/agent-run.yml
EOF_REQ
}

required_executables() {
  cat <<'EOF_REQ'
.mise/tasks/welcome
.mise/tasks/self
.mise/tasks/agent/list
.mise/tasks/agent/identity
.mise/tasks/agent/prepare
.mise/tasks/human
EOF_REQ
}

required_mise_tools() {
  cat <<'EOF_REQ'
shiv:shimmer
shiv:sessions
shiv:secrets
shiv:emails
shiv:rudi
shiv:notes
shiv:modules
shiv:codebase
EOF_REQ
}

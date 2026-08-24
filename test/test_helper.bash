tits() {
  if [ -z "${TITS_CALLER_PWD:-}" ]; then
    echo "TITS_CALLER_PWD not set" >&2
    return 1
  fi

  # Fixture Git operations must not consume ambient identity or signing config.
  cd "$REPO_DIR" && env \
    GIT_CONFIG_COUNT=0 \
    GIT_CONFIG_GLOBAL=/dev/null \
    GIT_CONFIG_NOSYSTEM=1 \
    mise run -q "$@"
}
export -f tits

setup() {
  export TITS_CALLER_PWD="$BATS_TEST_TMPDIR/caller"
  export MISE_STATE_DIR="$BATS_TEST_TMPDIR/mise-state"
  export GIT_AUTHOR_NAME="tits test"
  export GIT_AUTHOR_EMAIL="tits-test@example.invalid"
  export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
  export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
  mkdir -p "$TITS_CALLER_PWD" "$MISE_STATE_DIR"
}

make_home() {
  printf '%s/home' "$BATS_TEST_TMPDIR"
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    printf 'expected success, got status %s\noutput:\n%s\n' "$status" "$output" >&2
    return 1
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    printf 'expected failure, got success\noutput:\n%s\n' "$output" >&2
    return 1
  fi
}

assert_output_contains() {
  case "$output" in
    *"$1"*) ;;
    *)
      printf 'expected output to contain %s\noutput:\n%s\n' "$1" "$output" >&2
      return 1
      ;;
  esac
}

assert_file_exists() {
  [ -e "$1" ] || {
    printf 'expected file to exist: %s\n' "$1" >&2
    return 1
  }
}

assert_file_executable() {
  [ -x "$1" ] || {
    printf 'expected file to be executable: %s\n' "$1" >&2
    return 1
  }
}

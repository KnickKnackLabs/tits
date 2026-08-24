tits() {
  if [ -z "${TITS_CALLER_PWD:-}" ]; then
    echo "TITS_CALLER_PWD not set" >&2
    return 1
  fi

  cd "$REPO_DIR" && mise run -q "$@"
}
export -f tits

setup() {
  export TITS_CALLER_PWD="$BATS_TEST_TMPDIR/caller"
  export MISE_STATE_DIR="$BATS_TEST_TMPDIR/mise-state"
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

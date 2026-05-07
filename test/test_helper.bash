tits() {
  cd "$REPO_DIR" && CALLER_PWD="$CALLER_PWD" mise run -q "$@"
}
export -f tits

make_home() {
  export CALLER_PWD="$BATS_TEST_TMPDIR/caller"
  mkdir -p "$CALLER_PWD"
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

#!/usr/bin/env bats

load test_helper

@test "init creates a minimal home idempotently" {
  home="$(make_home)"

  run tits init --agent iris --home "$home" --skip-workflows
  assert_success
  assert_file_exists "$home/CLAUDE.md"
  assert_file_exists "$home/README.md"
  assert_file_exists "$home/README.tsx"
  assert_file_exists "$home/notes/status.md"
  [ "$(find "$home/notes" -maxdepth 1 -type f -exec basename {} \; | sort)" = "status.md" ]
  assert_file_exists "$home/mise.toml"
  assert_file_executable "$home/.mise/tasks/welcome"
  assert_file_executable "$home/.mise/tasks/agent/list"
  assert_file_executable "$home/.mise/tasks/agent/prepare"
  [ ! -e "$home/.tits/agent" ]
  git -C "$home" rev-parse --verify HEAD >/dev/null
  [ -z "$(git -C "$home" status --porcelain)" ]

  printf 'custom\n' > "$home/CLAUDE.md"
  run tits init --agent iris --home "$home" --skip-workflows
  assert_success
  [ "$(cat "$home/CLAUDE.md")" = "custom" ]
}

@test "init fixture ignores ambient Git signing config" {
  home="$(make_home)"

  export GIT_CONFIG_COUNT=3
  export GIT_CONFIG_KEY_0=commit.gpgsign
  export GIT_CONFIG_VALUE_0=true
  export GIT_CONFIG_KEY_1=gpg.format
  export GIT_CONFIG_VALUE_1=ssh
  export GIT_CONFIG_KEY_2=user.signingkey
  export GIT_CONFIG_VALUE_2="$BATS_TEST_TMPDIR/missing-signing-key"

  run tits init --agent iris --home "$home" --skip-workflows
  assert_success
  [ "$(git -C "$home" log -1 --format='%an <%ae>|%cn <%ce>')" = \
    "tits test <tits-test@example.invalid>|tits test <tits-test@example.invalid>" ]
  ! git -C "$home" cat-file commit HEAD | grep -q '^gpgsig '
}

@test "generated agent list and identity tasks execute" {
  home="$(make_home)"
  tits init --agent iris --home "$home" --skip-workflows

  run mise -C "$home" run -q agent:list
  assert_success
  [ "$output" = "iris" ]

  run mise -C "$home" run -q agent:identity iris
  assert_success
  assert_output_contains "# iris"
}

@test "init honors --no-commit" {
  home="$(make_home)"

  run tits init --agent iris --home "$home" --skip-workflows --no-commit
  assert_success
  run git -C "$home" rev-parse --verify HEAD
  assert_failure
  [ -n "$(git -C "$home" status --porcelain)" ]
}

@test "init rejects invalid agent names" {
  home="$(make_home)"

  run tits init --agent '../iris' --home "$home" --skip-workflows
  assert_failure
  assert_output_contains "agent must use lowercase"
}

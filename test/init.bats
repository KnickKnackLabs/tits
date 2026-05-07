#!/usr/bin/env bats

load test_helper

@test "init creates a minimal home idempotently" {
  home="$(make_home)"

  run tits init --agent iris --home "$home" --skip-workflows
  assert_success
  assert_file_exists "$home/CLAUDE.md"
  assert_file_exists "$home/notes/Status.md"
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

@test "generated agent list and identity tasks execute" {
  home="$(make_home)"
  tits init --agent iris --home "$home" --skip-workflows

  run bash -c "cd '$home' && mise run -q agent:list"
  assert_success
  [ "$output" = "iris" ]

  run bash -c "cd '$home' && mise run -q agent:identity iris"
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

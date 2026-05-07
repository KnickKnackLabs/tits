#!/usr/bin/env bats

load test_helper

@test "doctor fails on an empty directory" {
  home="$(make_home)"
  mkdir -p "$home"

  run tits doctor --home "$home"
  assert_failure
  assert_output_contains "missing git repo"
}

@test "doctor passes a scaffold with generated workflows" {
  home="$(make_home)"
  tits init --agent iris --home "$home" --skip-workflows
  mkdir -p "$home/.github/workflows"
  touch "$home/.github/workflows/agent-run.yml"
  touch "$home/.github/workflows/iris.yml"

  run tits doctor --home "$home"
  assert_success
  assert_output_contains "Home looks wakeable."
}

@test "doctor catches missing generated workflow" {
  home="$(make_home)"
  tits init --agent iris --home "$home" --skip-workflows
  mkdir -p "$home/.github/workflows"
  touch "$home/.github/workflows/agent-run.yml"

  run tits doctor --home "$home"
  assert_failure
  assert_output_contains "missing workflow for iris"
}

#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # When CI is re-run with debug logging (RUNNER_DEBUG=1), make `run` print the
  # $output of every command on failure. This surfaces the post-start hook log
  # captured by `run ddev restart`, which is otherwise swallowed on success.
  [ "${RUNNER_DEBUG:-}" = "1" ] && export BATS_VERBOSE_RUN=1

  # Override this variable for your add-on:
  export GITHUB_REPO=FreelyGive/ddev-playwright-cli

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH:-}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats:/usr/local/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site --omit-containers db,ddev-ssh-agent
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # Verify playwright-cli resolves on PATH in the web container. Guards against the
  # post-start hook regression where the binary was unreachable and later hooks
  # (chromium install, skills install) silently failed.
  run ddev exec command -v playwright-cli
  assert_success

  # Check skills were installed:
  run bats_pipe head -n 2 "${TESTDIR}/.claude/skills/playwright-cli/SKILL.md" \| tail -n 1
  assert_success
  assert_output "name: playwright-cli"

  # Check that the add-on is working:
  DDEV_DEBUG=true run ddev playwright-cli open https://example.com/
  assert_success
  assert_line "### Page"
  assert_line "- Page URL: https://example.com/"
  assert_line "- Page Title: Example Domain"

  # Verify chromium is the resolved default browser. Match the browserName field
  # specifically rather than a bare "chromium" substring, which also appears in
  # "chromiumSandbox" and would pass regardless of the resolved browser.
  run ddev playwright-cli config-print
  assert_success
  assert_output --partial '"browserName": "chromium"'
}

# Confirm the browser is provisioned by the install-browser hook itself, not as a
# side effect of npm's install-time download. Wipe the shared browser cache and
# restart with node_modules intact (npm install/ci are skipped), so the
# install-browser hook is the only thing that can re-provision the browser.
assert_browser_reinstalled_by_hook() {
  run ddev exec rm -rf /mnt/ddev-global-cache/playwright-browsers
  assert_success
  run ddev restart -y
  assert_success
  DDEV_DEBUG=true run ddev playwright-cli open https://example.com/
  assert_success
  assert_line "- Page Title: Example Domain"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
  assert_browser_reinstalled_by_hook
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
  assert_browser_reinstalled_by_hook
}

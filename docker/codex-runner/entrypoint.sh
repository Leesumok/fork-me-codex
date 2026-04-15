#!/usr/bin/env bash
set -euo pipefail

runner_dir="${ACTIONS_RUNNER_DIR:-/home/runner/actions-runner}"
work_dir="${RUNNER_WORKDIR:-_work}"
runner_labels="${RUNNER_LABELS:-codex}"
runner_name="${RUNNER_NAME:-codex-local}"

if [[ -n "${RUNNER_URL:-}" ]]; then
  runner_url="${RUNNER_URL}"
elif [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
  runner_url="https://github.com/${GITHUB_REPOSITORY}"
else
  echo "GITHUB_REPOSITORY or RUNNER_URL is required." >&2
  echo "Set GITHUB_REPOSITORY=owner/repo in .env." >&2
  exit 1
fi

cd "${runner_dir}"
mkdir -p "${work_dir}"

if ! command -v codex >/dev/null 2>&1; then
  echo "Codex CLI is not installed in this image." >&2
  exit 1
fi

if ! codex login status >/dev/null 2>&1; then
  echo "Codex CLI is not logged in for this runner volume." >&2
  echo "Run: docker compose run --rm codex-runner-login" >&2
  exit 1
fi

if [[ ! -f .runner ]]; then
  if [[ -z "${RUNNER_TOKEN:-}" ]]; then
    echo "RUNNER_TOKEN is required the first time this runner is configured." >&2
    echo "Create one in GitHub: Settings > Actions > Runners > New self-hosted runner." >&2
    exit 1
  fi

  ./config.sh \
    --url "${runner_url}" \
    --token "${RUNNER_TOKEN}" \
    --name "${runner_name}" \
    --labels "${runner_labels}" \
    --work "${work_dir}" \
    --unattended \
    --replace
fi

exec ./run.sh

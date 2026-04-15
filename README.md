# Fork Me Codex

Fork this repository to get a GitHub issue-to-PR automation template powered by Codex CLI and GitHub Actions.

This version is designed for a ChatGPT/Codex subscription account. It runs on a self-hosted GitHub Actions runner where Codex CLI is already logged in with OAuth. It does not require `OPENAI_API_KEY`.

The easiest setup path is local Docker Compose. The runner container registers itself with your fork, stores Codex OAuth credentials in a Docker volume, and executes Codex workflows from this repo.

## Quick Start

1. Fork this repository.
2. In the fork, open `Settings > Actions > Runners > New self-hosted runner`.
3. Copy the short-lived runner registration token from GitHub's setup command.
4. Create `.env` from the example:

```bash
cp .env.example .env
```

5. Edit `.env`:

```dotenv
GITHUB_REPOSITORY=your-user/your-fork
RUNNER_TOKEN=the_registration_token_from_github
RUNNER_NAME=codex-local
RUNNER_LABELS=codex
RUNNER_VERSION=latest
```

6. Build the runner image:

```bash
docker compose build
```

7. Log in to Codex inside the shared runner volume:

```bash
docker compose run --rm codex-runner-login
```

8. Start the runner:

```bash
docker compose up -d codex-runner
```

9. Confirm the runner appears as `Idle` in `Settings > Actions > Runners`.
10. Run the `Setup Codex labels` workflow once from the Actions tab.
11. Create an issue. Codex will triage new issues automatically.

The value in `RUNNER_TOKEN` is a GitHub runner registration token, not a Codex OAuth token. Codex OAuth credentials are created by `codex-runner-login` and stored in the `codex-home` Docker volume.

See [docs/self-hosted-runner.md](docs/self-hosted-runner.md) for details and reset instructions.

## Workflow

| Action | Result |
| --- | --- |
| Open an issue | Codex rewrites the issue into a clearer implementation spec. |
| Comment `@codex ...` on an issue | Codex treats the whole comment as maintainer feedback and updates the issue. |
| Add `code-gen` to an issue | Codex implements the issue on a `codex/issue-...` branch and opens or updates a PR. |
| Comment `@codex ...` on a PR | Codex treats the whole comment as PR feedback and updates the PR branch. |
| Add normal issue/PR comments without `@codex` | No Codex workflow runs. |

Examples:

```text
@codex 이 이슈를 한국어로 다시 정리해줘.
```

```text
@codex README 문장을 더 짧고 명확하게 줄여줘.
```

## Security Model

- Codex runs only for users with `write`, `maintain`, or `admin` permission on the repository.
- Codex runs only on a self-hosted runner labeled `codex`.
- Pull requests from external forks are not modified by OAuth-backed Codex workflows.
- This template does not auto-merge PRs.
- In Docker runner mode, Codex runs with its internal sandbox disabled because nested bubblewrap namespaces may fail inside Docker. Treat the Docker container and the trusted-maintainer checks as the execution boundary.

## Native Codex GitHub Review

OpenAI also supports native Codex GitHub review. This repository's workflows use `@codex` as a generic maintainer prompt trigger through your self-hosted runner's Codex CLI OAuth session. If native review is enabled too, avoid using this repository's generic `@codex` PR prompt for review requests unless you want both systems to react.

Official references:

- https://developers.openai.com/codex/cli
- https://developers.openai.com/codex/github-action
- https://developers.openai.com/codex/integrations/github
- https://developers.openai.com/codex/noninteractive

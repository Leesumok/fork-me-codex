# Fork Me Codex

Fork this repository to get a GitHub issue-to-PR automation template powered by Codex CLI and GitHub Actions.

This version is designed for a ChatGPT/Codex subscription account. It runs on a self-hosted GitHub Actions runner where Codex CLI is already logged in with OAuth. It does not require `OPENAI_API_KEY`.

The easiest setup path is local Docker Compose. The runner container registers itself with your fork, stores Codex OAuth credentials in a Docker volume, and executes the `@codex ...` workflows from this repo.

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
11. Create an issue and comment:

```text
@codex triage
```

The value in `RUNNER_TOKEN` is a GitHub runner registration token, not a Codex OAuth token. Codex OAuth credentials are created by `codex-runner-login` and stored in the `codex-home` Docker volume.

See [docs/self-hosted-runner.md](docs/self-hosted-runner.md) for details and reset instructions.

## Commands

| Label or command | Result |
| --- | --- |
| `@codex triage` | Rewrites an issue into a clearer implementation spec. |
| `codex:triage` | Rewrites an issue into a clearer implementation spec. |
| `@codex revise` | Revises an issue from the latest maintainer comment. |
| `codex:revise` | Allows the next issue comment workflow run to revise the issue. |
| `@codex implement` | Implements the issue on a `codex/issue-...` branch and opens a PR. |
| `codex:codegen` | Implements the issue on a `codex/issue-...` branch and opens a PR. |
| `@codex review` | Runs a workflow-based PR review and posts a comment. |
| `codex:review` | Runs a workflow-based PR review and posts a comment. |
| `@codex fix` | Applies PR comment or review feedback to the PR branch. |
| `@codex apply` | Same as `@codex fix`, with wording for review suggestions. |
| `codex:fix-pr` | Applies the latest PR feedback to the PR branch. |

## Security Model

- Codex runs only for users with `write`, `maintain`, or `admin` permission on the repository.
- Codex runs only on a self-hosted runner labeled `codex`.
- Issue triage, issue revision, and PR review use Codex read-only sandboxing.
- Code generation and PR feedback use Codex `--full-auto`, which keeps writes scoped to the checked-out workspace.
- Pull requests from external forks are not modified or reviewed by OAuth-backed Codex workflows.
- This template does not auto-merge PRs.

## Native Codex GitHub Review

OpenAI also supports native Codex GitHub review. After enabling it in Codex settings, comment `@codex review` on a PR or enable automatic reviews. This repository's workflows use the same command wording, but execute through your self-hosted runner's Codex CLI OAuth session. If native review is enabled too, disable this repo's `Codex PR review` workflow or use labels instead of `@codex review` to avoid duplicate reviews.

Official references:

- https://developers.openai.com/codex/cli
- https://developers.openai.com/codex/github-action
- https://developers.openai.com/codex/integrations/github
- https://developers.openai.com/codex/noninteractive

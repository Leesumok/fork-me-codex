# Self-hosted Codex runner

This template runs Codex through an OAuth login stored on a self-hosted GitHub Actions runner. It does not use `OPENAI_API_KEY`.

The recommended setup is Docker Compose. Manual local runner setup is still possible, but Compose makes the fork easier for other people to run.

## Docker Compose Setup

Create a self-hosted runner registration token:

1. Open your fork on GitHub.
2. Go to `Settings > Actions > Runners`.
3. Click `New self-hosted runner`.
4. Copy the token from the generated `./config.sh --url ... --token ...` command.

Create `.env`:

```bash
cp .env.example .env
```

Fill it in:

```dotenv
GITHUB_REPOSITORY=owner/repo
RUNNER_TOKEN=the_registration_token_from_github
RUNNER_NAME=codex-local
RUNNER_LABELS=codex
RUNNER_VERSION=latest
```

Build and log in:

```bash
docker compose build
docker compose run --rm codex-runner-login
```

The login command uses Codex device auth. Complete the browser flow with the ChatGPT/Codex subscription account you want the runner to use.

Start the runner:

```bash
docker compose up -d codex-runner
docker compose logs -f codex-runner
```

Confirm the runner appears as `Idle` in GitHub. It must have the `self-hosted` and `codex` labels.

## What Goes Where

- `RUNNER_TOKEN` in `.env` is a GitHub self-hosted runner registration token.
- `RUNNER_TOKEN` is not a Codex token and is not an OpenAI API key.
- Codex OAuth credentials are stored in the `codex-home` Docker volume after `codex-runner-login` succeeds.
- `.env` must not be committed.
- Docker volumes for this repo should be treated as sensitive because they contain the Codex login session.

## Reset

Stop the runner:

```bash
docker compose down
```

Remove only runner registration/config state:

```bash
docker volume rm fork-me-codex_runner-config fork-me-codex_runner-work
```

Remove Codex OAuth login state too:

```bash
docker volume rm fork-me-codex_codex-home
```

The volume names can differ if your Compose project name differs. Check them with:

```bash
docker volume ls
```

If the GitHub runner registration token expires before first startup, generate a new one in `Settings > Actions > Runners > New self-hosted runner` and update `.env`.

## Manual Setup

If you do not want Docker, install the runner directly on a Linux or macOS machine:

```bash
npm install -g @openai/codex
codex login --device-auth
codex login status
```

Then register the machine as a self-hosted runner under `Settings > Actions > Runners`, and add the `codex` label. The workflows in this repo use:

```yaml
runs-on: [self-hosted, codex]
```

## Security Notes

- Do not use a shared runner for untrusted repositories.
- Do not upload the runner home directory, Docker volumes, or Codex credential files as artifacts.
- Do not run OAuth-backed Codex workflows on PR branches from external forks.
- Keep the host patched and restrict Docker access to trusted maintainers.
- This template never auto-merges generated PRs.

## Commands

Issue comments:

- `@codex triage`
- `@codex revise`
- `@codex implement`

Pull request comments:

- `@codex review`
- `@codex fix`
- `@codex apply`

Labels still work for maintainers:

- `codex:triage`
- `codex:revise`
- `codex:codegen`
- `codex:fix-pr`
- `codex:review`

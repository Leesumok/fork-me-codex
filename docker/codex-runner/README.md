# Docker Codex runner image

This image contains:

- GitHub Actions runner
- Node.js 22
- Codex CLI
- Common build tools used by generated code tasks

The image does not contain Codex OAuth credentials. Credentials are created by running `codex login --device-auth` through the `codex-runner-login` Compose service and are stored in the `codex-home` Docker volume.

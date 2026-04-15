# Fork Me Codex

[English README](README.md)

이 저장소를 fork하면 Codex CLI와 GitHub Actions로 구동되는 GitHub issue-to-PR 자동화 템플릿을 사용할 수 있습니다.

이 버전은 ChatGPT/Codex 구독 계정을 기준으로 설계되었습니다. Codex CLI가 이미 OAuth로 로그인된 self-hosted GitHub Actions runner에서 실행됩니다. `OPENAI_API_KEY`는 필요하지 않습니다.

가장 쉬운 설정 방법은 로컬 Docker Compose를 사용하는 것입니다. runner container는 fork한 저장소에 직접 등록되고, Codex OAuth credentials를 Docker volume에 저장하며, 이 저장소의 Codex workflows를 실행합니다.

## 빠른 시작

1. 이 저장소를 fork합니다.
2. fork한 저장소에서 `Settings > Actions > Runners > New self-hosted runner`를 엽니다.
3. GitHub의 setup command에서 short-lived runner registration token을 복사합니다.
4. 예시 파일을 사용해 `.env`를 만듭니다.

```bash
cp .env.example .env
```

5. `.env`를 편집합니다.

```dotenv
GITHUB_REPOSITORY=your-user/your-fork
RUNNER_TOKEN=the_registration_token_from_github
RUNNER_NAME=codex-local
RUNNER_LABELS=codex
RUNNER_VERSION=latest
```

6. runner image를 빌드합니다.

```bash
docker compose build
```

7. 공유 runner volume 안에서 Codex에 로그인합니다.

```bash
docker compose run --rm codex-runner-login
```

8. runner를 시작합니다.

```bash
docker compose up -d codex-runner
```

9. `Settings > Actions > Runners`에서 runner가 `Idle` 상태로 표시되는지 확인합니다.
10. Actions tab에서 `Setup Codex labels` workflow를 한 번 실행합니다.
11. issue를 생성합니다. Codex가 새 issue를 자동으로 triage합니다.

`RUNNER_TOKEN` 값은 GitHub runner registration token이며 Codex OAuth token이 아닙니다. Codex OAuth credentials는 `codex-runner-login`이 생성하며 `codex-home` Docker volume에 저장됩니다.

자세한 내용과 reset 방법은 [docs/self-hosted-runner.md](docs/self-hosted-runner.md)를 참고하세요.

## 작업 흐름

| 동작 | 결과 |
| --- | --- |
| issue 열기 | Codex가 issue를 더 명확한 implementation spec으로 다시 작성합니다. |
| issue에 `@codex ...` comment 작성 | Codex가 comment 전체를 maintainer feedback으로 처리하고 issue를 업데이트합니다. |
| issue에 `code-gen` label 추가 | Codex가 `codex/issue-...` branch에서 issue를 구현하고 PR을 열거나 업데이트합니다. |
| PR에 `@codex ...` comment 작성 | Codex가 comment 전체를 PR feedback으로 처리하고 PR branch를 업데이트합니다. |
| `@codex` 없는 일반 issue/PR comment 추가 | Codex workflow가 실행되지 않습니다. |

예시:

```text
@codex 이 이슈를 한국어로 다시 정리해줘.
```

```text
@codex README 문장을 더 짧고 명확하게 줄여줘.
```

## 보안 모델

- Codex는 repository에 `write`, `maintain`, 또는 `admin` permission이 있는 사용자에 대해서만 실행됩니다.
- Codex는 `codex` label이 지정된 self-hosted runner에서만 실행됩니다.
- 외부 fork에서 온 pull request는 OAuth-backed Codex workflows로 수정되지 않습니다.
- 이 템플릿은 PR을 자동으로 merge하지 않습니다.
- Docker runner mode에서는 Docker 안에서 nested bubblewrap namespaces가 실패할 수 있기 때문에 Codex가 internal sandbox disabled 상태로 실행됩니다. Docker container와 trusted-maintainer checks를 execution boundary로 취급하세요.

## Native Codex GitHub Review

OpenAI는 native Codex GitHub review도 지원합니다. 이 저장소의 workflows는 self-hosted runner의 Codex CLI OAuth session을 통해 `@codex`를 일반적인 maintainer prompt trigger로 사용합니다. native review도 활성화되어 있다면 두 시스템이 모두 반응하기를 원하는 경우가 아니라면 review request에 이 저장소의 일반 `@codex` PR prompt를 사용하지 마세요.

공식 참고 자료:

- https://developers.openai.com/codex/cli
- https://developers.openai.com/codex/github-action
- https://developers.openai.com/codex/integrations/github
- https://developers.openai.com/codex/noninteractive

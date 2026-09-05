---
name: manage-agent-review-gate
description: 지정한 Git 저장소에 Codex 기반 pre-commit 지침 리뷰 게이트를 설치, 상태 확인, 업데이트 또는 삭제한다. 사용자가 저장소의 커밋 리뷰 훅 설치·활성화, 버전 및 변조 확인, 최신 템플릿 동기화, 훅 제거를 요청할 때 사용한다.
---

# Manage Agent Review Gate

지정한 저장소의 활성 Git hooks 경로에 강제형 Codex 리뷰 게이트를 관리한다.

## 실행 절차

1. 사용자가 지정한 저장소의 절대 경로를 확인한다.
2. 요청을 `install`, `status`, `update`, `uninstall` 중 하나로 판별한다.
3. `scripts/manage-gate.ps1`을 실행한다.
4. 명령 출력과 종료 코드를 사용자에게 그대로 요약한다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "<skill-root>\scripts\manage-gate.ps1" `
  -Action <install|status|update|uninstall> `
  -Repository "<absolute-repository-path>"
```

로컬에서 수정된 관리 파일을 의도적으로 덮어쓰거나, 변조된 설치를 삭제해야 한다고 사용자가 명시한 경우에만 `-Force`를 추가한다.

## 작업별 규칙

### install

- 대상이 유효한 Git 저장소인지 먼저 검증한다.
- 기존 `pre-commit`이 있으면 관리용 원본 파일로 이동하고 새 진입점에서 먼저 실행한다.
- 이미 관리 중이면 임의로 재설치하지 말고 `status` 또는 `update`를 사용한다.
- Codex CLI를 찾지 못하면 설치하지 않고 원인을 보고한다.

### status

- 설치 여부, 템플릿 버전, 누락 파일과 설치 후 수정된 파일을 확인한다.
- 상태 확인은 파일을 변경하지 않는다.

### update

- 설치 당시 해시와 현재 파일 해시를 비교한다.
- 설치 후 수정된 파일이 있으면 기본적으로 중단한다.
- 수정이 없으면 스킬에 포함된 최신 템플릿으로 교체하고 manifest를 갱신한다.

### uninstall

- 이 스킬이 관리하는 파일만 제거한다.
- 설치 전에 존재했던 `pre-commit`이 있으면 복원한다.
- 관리 파일이 설치 후 수정됐다면 기본적으로 중단한다.

## 안전 규칙

- 저장소 경로를 추측하지 않는다.
- 사용자가 지정하지 않은 저장소에 설치하거나 삭제하지 않는다.
- 기존 훅을 삭제하지 않는다.
- `git config core.hooksPath`를 임의로 변경하지 않는다.
- 훅은 자동으로 코드를 수정하거나 stage하거나 commit하지 않는다.

## 설치되는 동작

커밋할 staged 변경이 있으면 Codex CLI를 read-only·ephemeral 모드로 실행한다. Codex는 저장소와 상위 경로의 적용 가능한 `AGENTS.md` 및 그 문서가 명시적으로 연결한 지침을 탐색한다. 위반이 없을 때만 `PASS`로 커밋을 허용하며, 위반 또는 CLI 오류가 있으면 커밋을 차단한다.

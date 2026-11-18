# backend-agent-docs

백엔드 개발 에이전트의 지침, 공통 standards, 재사용 템플릿을 관리하는 저장소입니다.

## 구조

```text
AGENTS.md
docs/
  agents/
  standards/
  templates/
```

- `AGENTS.md`: 저장소 라우팅과 공통 운영 규칙
- `docs/agents/`: 구현, 테스트, 리뷰 전용 에이전트 정의
- `docs/standards/architecture.md`: package, 계층, 의존 방향과 구조 기준
- `docs/standards/domain-implementation.md`: Service 책임, 유스케이스, 상태 전이와 transaction 기준
- `docs/standards/coding-conventions.md`: Java, Lombok, 모델, 이름, formatting과 주석 기준
- `docs/standards/persistence.md`: JPA·JDBC, DAO, query, schema와 DB 검증 기준
- `docs/standards/configuration.md`, `client-contracts.md`, `module-integration.md`: 설정, API 계약과 모듈 연동 기준
- `docs/standards/implementation-workflow.md`, `feature-work-document.md`: 구현 흐름과 복합 작업의 로컬 계획서 작성 기준
- `docs/standards/testing.md`, `mismatch-prevention-checklist.md`, `review-and-quality-gates.md`: 테스트, 누락 점검과 리뷰 판정 기준
- `docs/standards/commit-conventions.md`: 사용자가 commit을 요청했을 때 적용하는 공통 기준
- `docs/templates/`: 재사용 가능한 산출물 템플릿

프로젝트별 요구사항, 스키마, 메모와 실제 제품 코드는 이 저장소에서 관리하지 않습니다. 작업 시 대상 워크스페이스 또는 외부 프로젝트 저장소에 존재하는 문서를 입력으로 사용합니다.

## Codex 플러그인

플러그인은 Java·Spring 백엔드 구현과 개발 테스트 표준, SQL 템플릿을 `backend-agent-docs:spring-backend-guidance` 스킬의 참조 자료로 묶습니다. 패키지를 만들 때 저장소의 원본 문서를 사용합니다.

이 저장소를 Codex 데스크톱에서 열고 **Plugins → Backend Guidance → Backend Agent Docs → 설치**를 선택합니다. 목록에 새 마켓플레이스가 보이지 않으면 앱을 다시 열어 목록을 새로고침합니다. 마켓플레이스는 이 저장소의 플러그인을 설치 화면에 표시하는 목록이며, 설치할 패키지도 저장소에 포함되어 있습니다.

Codex 채팅에서 **“이 PC에 백엔드 공통 지침 플러그인 설치해줘”**라고 요청해도 됩니다.

적용할 프로젝트의 루트 `AGENTS.md`에서 공통 지침을 다음과 같이 지정합니다. 프로젝트 전용 지침은 그 파일에서 계속 관리합니다.

> Spring 백엔드 구현과 개발 테스트에는 `backend-agent-docs:spring-backend-guidance` 스킬을 읽고 변경 영역에 해당하는 공통 개발 표준을 적용한다.

공통 지침을 수정한 뒤에는 이 저장소의 Codex 채팅에서 **“백엔드 공통 지침 갱신해줘”**라고 요청합니다. Codex가 원본과 배포본을 비교하고, 바뀐 경우에만 패키지 버전을 올린 뒤 이 PC의 설치본까지 갱신하고 검증합니다. 적용할 프로젝트에서는 새 채팅을 시작합니다.

- `.agents/plugins/marketplace.json`은 데스크톱 설치 목록입니다.
- `plugins/backend-agent-docs/`는 설치 가능한 배포본입니다.
- 원본은 `docs/`와 `tools/codex-plugin/SKILL.md`에서 수정합니다. 배포본 동기화에는 `tools/update-codex-plugin.ps1`을 사용합니다.

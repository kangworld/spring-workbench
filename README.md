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

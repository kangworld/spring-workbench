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
- `docs/standards/`: 아키텍처, 코드, DB, 테스트, 리뷰 공통 기준
- `docs/templates/`: 재사용 가능한 산출물 템플릿

프로젝트별 요구사항, 스키마, 메모와 실제 제품 코드는 이 저장소에서 관리하지 않습니다. 작업 시 대상 워크스페이스 또는 외부 프로젝트 저장소에 존재하는 문서를 입력으로 사용합니다.

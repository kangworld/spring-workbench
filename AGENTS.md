# AGENTS

이 저장소는 백엔드 개발 자동화를 위한 글로벌 에이전트 허브입니다.
목표는 백엔드 구현, 테스트, 리뷰에 필요한 에이전트 지침과 공통 기준을 독립적으로 관리하는 것입니다.

## 1) 기본 원칙
- 본 저장소는 에이전트 지침, 공통 standards, 재사용 템플릿 관리용으로 사용합니다.
- 실제 코드 구현/수정은 대상 외부 프로젝트 레포에서 수행합니다.
- 프로젝트별 요구사항, 스키마, 메모의 저장 위치와 이력은 대상 워크스페이스 또는 별도 산출물 저장소가 관리합니다.
- 요구사항과 스키마가 존재하면 구현·테스트·리뷰의 입력으로 사용하되, 이 저장소가 해당 산출물 경로를 강제하지 않습니다.
- 표준 문서는 전역 기본값이며, 대상 프로젝트의 기존 운영 규약과 충돌하는 경우 관련 `standards` 문서의 예외 기록 기준을 따라 문서화합니다.
- 익숙하지 않은 기술, 패턴, 인프라, 런타임 기능을 다루는 경우 바로 설계하지 말고 먼저 조사합니다. 가능하면 기존 표준 패턴, 내장 기능, 운영 중인 선례를 우선 검토합니다.
- 해결 가능한 범위의 엣지 케이스, 실패 경로, 테스트는 후속 작업으로 미루지 않고 현재 작업에서 닫는 것을 기본으로 합니다. 범위가 과도하게 커지는 경우에만 별도 작업으로 분리하고 이유를 남깁니다.
- 에이전트는 대안과 권고를 제시할 수 있지만, 사용자 또는 작업 소유자의 방향을 바꾸는 결정은 승인 없이 확정하지 않습니다.

## 2) 전용 에이전트
아래 문서는 이 저장소의 표준 에이전트 정의이며, 작업 성격에 맞게 선택/조합합니다.

1. Implementation Agent
- 문서: `docs/agents/implementation-agent.md`
- 역할: 기존 요구사항, 스키마, 프로젝트 규칙과 코드 구조를 바탕으로 외부 프로젝트 레포 코드 구현
- 참고 기준:
  - `docs/standards/architecture.md`
  - `docs/standards/domain-implementation.md`
  - `docs/standards/coding-conventions.md`
  - `docs/standards/persistence.md`
  - `docs/standards/configuration.md`
  - `docs/standards/client-contracts.md`
  - `docs/standards/module-integration.md`
  - `docs/standards/implementation-workflow.md`
  - `docs/standards/feature-work-document.md`
  - `docs/standards/testing.md`
  - `docs/standards/mismatch-prevention-checklist.md`

2. Test Agent
- 문서: `docs/agents/test-agent.md`
- 역할: 구현 변경사항에 대한 테스트 작성/보강 및 회귀 위험 점검
- 참고 기준:
  - `docs/standards/testing.md`
  - `docs/standards/coding-conventions.md`
  - `docs/standards/persistence.md`
  - `docs/standards/configuration.md`
  - `docs/standards/mismatch-prevention-checklist.md`

3. Review Agent
- 문서: `docs/agents/review-agent.md`
- 역할: 적용 가능한 요구사항·스키마, 구현 변경, 테스트 결과를 기준으로 심각도 기반 리뷰와 품질 게이트를 수행
- 주요 산출물: `리뷰 리포트`, `코드 리뷰 코멘트`, `잔여 리스크 목록`

## 3) 공통 기준 문서
- 아키텍처와 패키지 기준: `docs/standards/architecture.md`
- 도메인 구현과 서비스 책임: `docs/standards/domain-implementation.md`
- Java 코딩 규칙과 Lombok·주석 기준: `docs/standards/coding-conventions.md`
- 영속성과 스키마 기준: `docs/standards/persistence.md`
- 설정과 런타임 구성 기준: `docs/standards/configuration.md`
- 클라이언트·API 계약 경계: `docs/standards/client-contracts.md`
- 공통 모듈과 의존성 통합: `docs/standards/module-integration.md`
- 구현 작업 흐름: `docs/standards/implementation-workflow.md`
- 피처 작업 문서 규약: `docs/standards/feature-work-document.md`
- 테스트/검증 기준: `docs/standards/testing.md`
- 미스매치 방지 체크리스트: `docs/standards/mismatch-prevention-checklist.md`
- 커밋 메시지와 범위 기준: `docs/standards/commit-conventions.md`
- 리뷰/품질 게이트 기준: `docs/standards/review-and-quality-gates.md`
- 스키마 템플릿: `docs/templates/schema-template.sql`

## 4) 권장 실행 순서

1. 작업 대상 식별: 대상 외부 레포 경로, 기능 범위, 적용 지침 확정
2. 입력 기준 확인: 기존 요구사항, 스키마, 프로젝트 규칙과 현재 코드 구조 확인
3. Implementation Agent 실행: 외부 레포 코드 변경
4. Test Agent 실행: 테스트 작성/실행 및 리스크 점검
5. Review Agent 실행: 보안/품질/성능/테스트 관점 최종 리뷰 및 품질 게이트 상태 판정

### 공통 지침 플러그인 설치·갱신

- 사용자가 “백엔드 공통 지침 설치해줘” 또는 “백엔드 공통 지침 갱신해줘”라고 요청하면 이 저장소에서 `tools/update-codex-plugin.ps1`을 실행하고 설치된 버전을 확인합니다. 사용자는 채팅에서 요청하면 됩니다.
- `docs/`와 `tools/codex-plugin/SKILL.md`가 배포 파일의 원본입니다. 배포본에 변경이 있으면 스크립트가 `plugins/backend-agent-docs/`를 동기화하고 패치 버전을 올립니다. 패키지만 만들거나 검증할 때는 `-PackageOnly`를 사용합니다.
- 스크립트가 별도 권한으로 실행되어야 하면 이 PC에서 사용 중인 Codex 프로필에 설치되도록 실행 환경을 확인합니다.

## 5) 운영 규칙
- 불확실한 항목은 문서에 `미정/질문`으로 명시하고 임의 확정하지 않습니다.
- 문서에 변경 이력 섹션이나 날짜별 변경 기록을 작성하지 않습니다.
- 구현 변경 시 현재 작업에 적용되는 요구사항, 스키마, 테스트 기준과 정합성을 유지합니다.
- 코드, 정책, 스키마 변경이 기존 요구사항/스키마/테스트/메모 문서에 영향을 주면 같은 작업 안에서 가능한 범위까지 함께 갱신합니다.
- 문서는 보통 이번 작업에서 함께 고칩니다. 다만 아직 방향이 확정되지 않았거나, 실험 중이거나, 문서까지 같이 고치면 이번 작업이 너무 커지는 경우에는 나중에 고칠 수 있습니다. 이때는 왜 지금 안 고치는지와, 나중에 어떤 문서를 고쳐야 하는지 꼭 남깁니다.
- 대상 외부 프로젝트 레포에서는 AI 작업 문서와 AI 운영 보조 파일을 커밋에 포함하지 않습니다. 예: 대상 저장소의 `commit-reviews/`, `api/`, `development-steps.md`, 기타 에이전트 점검용 메모 / draft 문서. 이런 파일은 사용자가 명시적으로 커밋을 지시하기 전까지 작업트리에만 둡니다.
- 이 지침을 적용하는 Spring 프로젝트의 기본 데이터 접근 기술은 Spring Data JPA와 Hibernate입니다.
- 기존 JDBC·MyBatis·R2DBC 구현의 마이그레이션 여부는 호환성, 쿼리 특성, 성능과 운영 위험을 확인해 별도로 결정합니다. 신규 작업에서 JPA 이외의 기술을 선택하면 검증 가능한 이유와 적용 범위를 프로젝트 전용 문서에 남깁니다.
- JDBC 구현체는 SQL 실행과 row 매핑, 기술 예외의 저장소 계약 변환에 집중합니다. 조회 결과 없음은 `Optional.empty()`처럼 DAO 계약으로 바꿀 수 있지만, update count 0처럼 도메인 상태 판단이 필요한 결과를 DAO 내부에서 도메인 예외나 임의 `IllegalStateException`으로 바꾸지 않습니다. 이 경우 JDBC는 count를 반환하고 서비스가 업무 의미에 맞는 예외를 결정합니다.
- 대규모 리팩터링은 기능 변경과 분리해 관리합니다.
- 운영 영향이 있는 변경은 관련 산출물에 마이그레이션/롤백 전략을 함께 기록합니다.
- 전역 규약 예외가 필요한 경우 해당 `standards` 문서에 정의된 예외 기록 기준을 따릅니다.
- `notes.md`는 피처 단위의 검토 메모이며, `Learnings`는 다음 작업에서도 재사용할 가치가 있는 교훈입니다.
- `notes.md`에 남긴 판단이 최종 구현 기준으로 굳어지면 `backend-requirements.md` 또는 `schema.sql`로 승격하고, 메모에만 고립시키지 않습니다.
- 구현 작업을 마치기 전에는 반드시 변경 코드에 필요한 주석이 들어갔는지 검증합니다. 단순 컴파일/테스트 통과와 별개로, 핵심 로직, 의도, 제약, 운영상 주의점이 주석 없이 남아 있지 않은지 최종 확인합니다.
- 클래스와 인터페이스 선언 바로 위에는 설명 주석이나 JavaDoc을 작성하지 않습니다. 메서드·필드·record·enum과 내부 로직의 필요한 문서는 이 금지 대상이 아닙니다.

## 6) 공통 완료 상태
- `DONE`: 작업이 정상 완료되었고, 핵심 판단과 검증 근거가 함께 제시된 상태
- `DONE_WITH_CONCERNS`: 작업은 완료되었지만 잔여 리스크, 미검증 지점, 후속 확인 사항이 남은 상태
- `BLOCKED`: 현재 정보나 환경으로는 진행이 불가능한 상태
- `NEEDS_CONTEXT`: 진행을 위해 추가 입력, 결정, 대상 경로, 기준 문서가 필요한 상태

## 7) 공통 중단 및 에스컬레이션 규칙
- 동일 문제를 3회 시도해도 해결하지 못하면 더 밀어붙이지 말고 중단한 뒤 `BLOCKED` 또는 `NEEDS_CONTEXT`로 보고합니다.
- 보안 민감 변경, 데이터 정합성 훼손 가능 변경, 운영 영향이 큰 변경을 충분히 검증하지 못하면 중단하고 추가 확인이 필요한 이유를 명시합니다.
- 현재 작업 범위에서 품질을 보장할 수 없는 경우 억지로 완료 처리하지 말고, 검증하지 못한 범위와 권장 다음 행동을 함께 남깁니다.
- 에스컬레이션 보고는 최소한 다음 항목을 포함합니다.
  - `STATUS`: `BLOCKED` 또는 `NEEDS_CONTEXT`
  - `REASON`: 왜 멈췄는지
  - `ATTEMPTED`: 무엇을 확인하거나 시도했는지
  - `RECOMMENDATION`: 다음에 무엇을 해야 하는지

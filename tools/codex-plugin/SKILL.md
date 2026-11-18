---
name: spring-backend-guidance
description: Apply shared Java and Spring coding standards to implementation, troubleshooting, or development tests in projects that opt in through AGENTS.md.
---

# Spring 백엔드 공통 지침

대상 프로젝트의 `AGENTS.md`와 프로젝트 전용 규칙을 먼저 확인한다.
요구사항, 스키마, 실제 코드와 테스트를 대조한 뒤 변경하는 영역에 해당하는 표준을 읽는다. 아래 경로는 설치된 이 스킬의 `references/`를 기준으로 한다.

- 패키지, 계층, 의존 방향은 `docs/standards/architecture.md`
- 서비스 책임, 업무 흐름, 상태 전이와 트랜잭션은 `docs/standards/domain-implementation.md`
- Java, Lombok, 이름과 주석은 `docs/standards/coding-conventions.md`
- JPA, JDBC, 쿼리와 스키마는 `docs/standards/persistence.md`. SQL 초안이 필요하면 `docs/templates/schema-template.sql`을 참고한다.
- 설정, 프로필, Spring 빈과 운영 구성은 `docs/standards/configuration.md`
- API 요청·응답, 직렬화와 소비자 계약은 `docs/standards/client-contracts.md`
- 공통 모듈과 의존성 호환성은 `docs/standards/module-integration.md`
- 개발 테스트와 회귀 검증은 `docs/standards/testing.md`

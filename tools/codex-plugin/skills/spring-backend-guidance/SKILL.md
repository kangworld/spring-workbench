---
name: spring-backend-guidance
description: Implement or troubleshoot Java and Spring backend changes using the project's declared technology stack and shared development standards.
---

# Spring 백엔드 구현

대상 프로젝트의 `AGENTS.md`, 요구사항과 테스트를 확인하고 작업할 모듈과 기술 스택을 파악합니다.

테스트·검증만 요청받으면 [검증 역할](../../references/docs/roles/verifier.md), 코드 검토만 요청받으면 [검토 역할](../../references/docs/roles/reviewer.md)을 바로 적용합니다.

1. 계약이나 버그 원인이 불명확하면 [조사 역할](../../references/docs/roles/investigator.md)로 원인과 변경 범위를 좁힙니다.
2. 코드 수정에는 [구현 역할](../../references/docs/roles/implementer.md)과 [개발 기준 인덱스](../../references/docs/guidance/development/README.md)를 적용합니다.
3. 저장소·DAO·쿼리·스키마 변경에는 [영속성 인덱스](../../references/docs/guidance/persistence/README.md)에서 공통 기준과 변경 경로에 해당하는 기술 기준을 적용합니다. 스키마 초안이 필요하면 [SQL 템플릿](../../references/docs/templates/schema-template.sql)을 참고합니다.
4. 구현을 마치면 [검증 역할](../../references/docs/roles/verifier.md)에 따라 변경을 검증합니다.

역할은 작업의 책임입니다. 간단한 작업은 현재 세션에서 수행합니다. 사용자가 위임을 요청했거나 적용되는 프로젝트 지침이 위임을 명시한 경우, 역할 문서와 대상 경로, 계약, 확인한 근거, 기대 산출물을 전달합니다. 호스트가 지원하는 내장 역할 중 조사는 `explorer`, 코드 수정은 `worker`로 맡길 수 있습니다. 같은 파일을 여러 역할에 동시에 수정하도록 배정하지 않습니다.

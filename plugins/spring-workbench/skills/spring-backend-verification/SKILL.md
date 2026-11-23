---
name: spring-backend-verification
description: Validate Java and Spring backend changes, design or run regression tests, or perform a requested code review using shared standards.
---

# Spring 백엔드 검증

프로젝트의 `AGENTS.md`에서 테스트 명령, 대상 모듈의 기술 스택, 프로젝트 전용 검증 규칙을 확인합니다.

- 테스트 설계·실행과 회귀 검증은 [검증 역할](../../references/docs/roles/verifier.md)을 적용합니다. [검증 인덱스](../../references/docs/guidance/verification/README.md)에서 공통 테스트 기준과 변경 경계의 기술 지침을 선택합니다.
- 실패 원인 분석이 필요하면 [조사 역할](../../references/docs/roles/investigator.md)과 [디버깅 지침](../../references/docs/guidance/verification/common/debugging.md)을 사용합니다.
- 코드 검토를 요청받으면 [검토 역할](../../references/docs/roles/reviewer.md)에 따라 실제 변경과 계약을 대조합니다. 프로젝트가 허용하는 범위의 기술 검토로 완료합니다.
- DB 동작을 검증할 때는 [영속성 인덱스](../../references/docs/guidance/persistence/README.md)에서 해당 기술과 DB 기준을 확인합니다.

구현의 지침 준수나 작성된 테스트의 품질을 별도로 검증해 달라는 요청에는 각각 [구현 준수 검증](../spring-backend-implementation-audit/SKILL.md), [테스트 품질 검증](../spring-backend-test-audit/SKILL.md)을 적용합니다.

실행한 명령과 결과를 기록하고, 기존 실패와 이번 변경으로 인한 실패를 근거로 구분합니다. 사용자가 위임을 요청했거나 프로젝트 지침이 위임을 명시한 경우 사례, 영향 경로, 확인할 근거와 결과 형식을 함께 전달합니다.

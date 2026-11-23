---
name: spring-backend-implementation-audit
description: Audit Java and Spring backend implementation against project contracts and applicable Spring Workbench development standards during implementation closeout or a standalone conformance check.
---

# Spring 백엔드 구현 준수 검증

구현 작업의 완료 단계에서는 아래 기준으로 실제 변경을 검증하고 발견 사항을 [구현 작업 흐름](../../references/docs/guidance/workflow/common/implementation-workflow.md#5-완료-게이트)에 전달합니다. 단독 검증 요청에는 발견 사항을 보고하고, 수정도 요청받은 경우 반영한 뒤 다시 확인합니다.

1. 요청한 변경 범위와 비교 기준을 확정합니다. 기준이 따로 없으면 현재 변경을 확인하고 보고서에 비교 기준을 적습니다. 대상 `AGENTS.md`, 요구사항, API 계약, 스키마와 모듈별 기술 스택에서 검증에 필요한 기준을 찾습니다.
2. [개발 기준](../../references/docs/guidance/development/README.md)과 [영속성 기준](../../references/docs/guidance/persistence/README.md)에서 변경 경로의 공통·기술별 항목을 고릅니다. [미스매치 방지 체크리스트](../../references/docs/guidance/verification/common/mismatch-prevention-checklist.md)의 계약, 구현, 모듈, 설정, DB 항목 가운데 적용되는 항목을 확인합니다.
3. 실제 diff와 호출 경로를 읽고 의도와 동작을 대조합니다. 변경이 닿는 경계에서 API 호환성, 계층 책임, 상태 전이와 실패 처리, 설정 적용, 데이터 정합성, Java 주석을 확인합니다. 트랜잭션이나 프레임워크 동작을 정적 검토로 확인하기 어려우면 가능한 범위에서 관련 검증을 실행합니다.
4. 발견 사항마다 심각도, 코드 위치, 적용 기준과 근거, 영향, 수정 방향을 기록합니다. 프로젝트 정책이 미정이거나 근거가 부족한 항목은 미확인으로 남깁니다. 이미 문서화된 예외는 대상 경로와 조건이 일치하는지 확인합니다.

발견 사항이 없으면 확인한 변경 범위와 적용 기준을 적습니다. 실행한 검증의 결과와 실행하지 못한 항목의 이유를 남깁니다.

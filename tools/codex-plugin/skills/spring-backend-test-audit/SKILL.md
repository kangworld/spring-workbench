---
name: spring-backend-test-audit
description: Audit Java and Spring backend tests for missing scenarios, ineffective assertions, and inappropriate test boundaries during implementation closeout or a standalone test quality check.
---

# Spring 백엔드 테스트 품질 검증

구현 작업의 완료 단계에서는 아래 기준으로 테스트의 범위와 검증력을 확인하고 발견 사항을 [구현 작업 흐름](../../references/docs/guidance/workflow/common/implementation-workflow.md#5-완료-게이트)에 전달합니다. 단독 검증 요청에는 발견 사항을 보고하고, 테스트 보완도 요청받은 경우 반영한 뒤 다시 확인합니다.

1. 대상 프로젝트의 `AGENTS.md`에서 테스트 명령과 대상 모듈의 스택을 확인합니다. 요구사항, 변경된 동작과 사용자 흐름에서 검증할 시나리오를 먼저 추립니다. 변경 파일 밖에서 이미 그 동작을 검증하는 테스트도 확인합니다.
2. [테스트 기준](../../references/docs/guidance/verification/common/testing.md), [미스매치 방지 체크리스트의 테스트 항목](../../references/docs/guidance/verification/common/mismatch-prevention-checklist.md#7-테스트), [기술별 검증 지침](../../references/docs/guidance/verification/README.md#기술별-검증)을 적용합니다. 관련 정상·실패·경계 조건을 테스트에 대응시키고, 버그 수정이라면 원래 실패 경로를 회귀 테스트가 밟는지 확인합니다.
3. 테스트 본문과 픽스처를 읽습니다. 실제 호출과 단언이 계약 위반을 잡아내는지, 테스트가 보호하려는 빈·트랜잭션·DB 경계를 mock이 가리는지 확인합니다. 순서나 공유 상태 등 실행 환경에 의존해 우연히 통과할 여지도 살핍니다.
4. 가능한 범위에서 프로젝트의 명령으로 관련 테스트를 실행하고, 대상 테스트가 실제로 실행됐는지 결과에서 확인합니다. 실패 원인을 판단할 근거가 부족하면 미확인으로 기록합니다.

발견 사항마다 시나리오, 테스트 또는 구현 위치, 적용 기준, 놓칠 수 있는 회귀와 보완 방향을 적습니다. 실행 명령과 결과, 미검증 범위도 함께 남깁니다.

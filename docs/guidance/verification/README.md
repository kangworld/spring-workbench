# 개발 검증 지침

## 공통 검증

| 작업 | 지침 |
| --- | --- |
| 테스트 범위, 경계값, 실패 경로와 실행 증거 | [테스트](common/testing.md) |
| 버그 재현, 원인 확인과 근거 기록 | [디버깅](common/debugging.md) |
| 계약·코드·테스트의 누락 확인 | [누락 점검](common/mismatch-prevention-checklist.md) |

## 기술별 검증

| 검증 대상 | 추가 지침 |
| --- | --- |
| Spring 빈, 프록시, 트랜잭션, 실제 프로필과 설정의 조립 | [Spring 통합 테스트](implementations/spring/integration-testing.md) |
| JUnit으로 작성하는 Java 테스트 | [JUnit 작성 기준](implementations/junit/test-style.md) |
| DB 통합 테스트에서 데이터 준비, 자원 설정과 정리 | [DB 테스트 자원](implementations/database/fixtures.md), [영속성 인덱스](../persistence/README.md) |

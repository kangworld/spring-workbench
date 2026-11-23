# 서버 개발 지침

## 공통 개발 기준

| 변경 영역 | 적용 문서 |
| --- | --- |
| 패키지, 계층, 의존 방향 | [아키텍처](common/architecture.md) |
| 서비스 책임, 업무 흐름과 상태 전이 | [도메인 구현](common/domain-implementation.md) |
| 설정 소유권과 운영값 결정 | [설정](common/configuration.md) |
| API 요청·응답, 직렬화, 소비자 동작 | [클라이언트 계약](common/client-contracts.md) |
| 모듈 재사용, 의존성 버전과 런타임 호환성 | [모듈 통합](common/module-integration.md) |

## 기술별 구현 기준

대상 프로젝트의 `AGENTS.md`와 변경되는 코드·빌드 설정에서 기술을 확인하고 해당 문서를 읽습니다.

| 변경 영역 | 추가 지침 |
| --- | --- |
| Java 이름, 타입, 모델, 주석 | [Java 코딩 기준](implementations/java/coding-conventions.md) |
| Java 모듈의 Lombok 정책, 애너테이션 처리, 생성자·빌더 | [Lombok](implementations/lombok/usage.md) |
| JVM 바이너리 호환성과 의존성 연결 | [Java 모듈 호환성](implementations/java/module-linkage.md) |
| Spring 프로필, 속성 바인딩과 빈 | [Spring 설정](implementations/spring/configuration.md) |
| Spring 쓰기 트랜잭션, 프록시와 전파 | [Spring 트랜잭션](implementations/spring/transactions.md) |
| Jackson으로 처리하는 API 또는 DB JSON | [Jackson](implementations/jackson/serialization.md) |

## 관련 지침

| 변경 영역 | 인덱스 |
| --- | --- |
| DAO, 리포지토리, SQL, 스키마 | [영속성](../persistence/README.md) |
| 개발 테스트, 회귀 검증 | [검증](../verification/README.md) |

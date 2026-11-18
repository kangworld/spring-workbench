# 아키텍처 기준

## 적용 원칙

- 대상 프로젝트의 기존 구조, 반복 패턴과 운영 규약을 먼저 확인합니다.
- 요구사항과 DB·API 계약이 전역 기본값보다 우선하며, 충돌 시 호환성과 운영 안정성을 검토합니다.
- 익숙하지 않은 기술, 패턴과 런타임 기능은 바로 설계하지 않고 표준 패턴, 내장 기능과 운영 선례를 조사합니다.
- 프로젝트 고유 규약의 예외가 필요하면 이유, 영향 범위, 호환성, 배포와 롤백 전략을 기록합니다.

## 1) 패키지와 계층

- application root 바로 아래 패키지는 `api`, `service`, `dao`, `model` 같은 전역 기술 계층이 아니라 실제 도메인·기능 소유권을 표현합니다.
- 기능 패키지 아래에서는 `api`, `service`, `dao`, `entity`, `domain`, `exception`으로 책임을 분류합니다. 여러 성격의 클래스를 기능 루트나 포괄적인 `model` 패키지에 함께 모으지 않습니다.
- `entity`에는 JPA annotation, 영속성 식별자·연관관계와 persistence lifecycle을 가진 클래스만 둡니다. JPA와 무관한 계산 결과, 값 객체, 정책과 업무 상태를 `entity`에 두지 않습니다.
- `domain`에는 Spring·JPA·HTTP와 무관하게 계산, 검증, 상태와 업무 불변식을 표현하는 순수 Java 클래스를 둡니다. 업무 의미를 가진 enum도 기본적으로 `domain`이 소유합니다.
- 특정 use-case의 입력·출력·실행 context는 `service/model`, JPQL·SQL 조회 결과 형태는 `dao/projection`, 외부 요청·응답은 `api/request`와 `api/response`에 둡니다.
- JPA entity와 domain class를 패키지 형식을 맞추기 위해 일대일로 복제하지 않습니다. 영속성 관심사와 무관한 별도 업무 모델이 실제로 필요할 때만 변환 경계와 함께 분리합니다.
- `domain/value`, `domain/policy`, `domain/result`처럼 더 세분화한 패키지는 같은 책임의 클래스가 반복되고 탐색성이 실제로 나아질 때만 추가합니다. 파일 하나를 담기 위한 하위 패키지를 만들지 않습니다.
- `service/impl`에는 Service 구현을 두되, 패키지 형식을 맞추기 위해 의미 없는 interface를 만들지는 않습니다. 계약이 현재 모듈이나 외부 공통 모듈에 실제로 존재할 때 구현 관계를 유지합니다.
- `editor`, `component`, `handler`, `processor`, `verification`, `initialization`, `command/handler`, `command/payload` 같은 추가 패키지는 실제로 반복되는 독립 책임이 있을 때만 만듭니다.
- `common`, `shared`, `util`은 임시 대피소로 사용하지 않습니다. 둘 이상의 기능이 실제로 공유하고 독립된 책임 이름을 붙일 수 있는 코드만 목적이 드러나는 하위 패키지로 이동합니다.
- 테스트 패키지는 운영 코드 패키지를 그대로 따라 package-private 경계와 탐색 위치를 유지합니다.
- 새 패키지를 만들기 전에 현재 코드의 인접 기능과 같은 계층의 반복 배치를 확인합니다. 파일 하나마다 action·policy·helper 패키지를 기계적으로 만들지 않습니다.
- service 책임은 조회·계획·저장 같은 기술 단계가 아니라 상태를 소유한 도메인 유스케이스로 나눕니다. transaction coordinator는 도메인 간 실행 순서만 조정하며 `*PlanService`, `*PersistenceService` 같은 단계별 service로 규칙과 상태 변경을 옮기지 않습니다.
- 새 Properties 클래스, wrapper, context, helper는 이름을 붙일 수 있다는 이유만으로 만들지 않습니다. 수명주기, 경계, 반복 제거, 가독성 중 명확한 이득이 있어야 합니다.
- 같은 입력 규칙을 여러 service overload에서 반복 검사하지 않습니다. 모든 호출 경로가 반드시 지나는 모델 생성이나 핵심 계산 경계에서 한 번 검증합니다.

### 패키지 구조 워스트

```text
feature/
├─ FeatureController.java
├─ FeatureExceptionHandler.java
├─ FeatureService.java
├─ FeatureServiceImpl.java
├─ FeatureDao.java
├─ Feature.java
├─ FeatureCalculation.java
├─ FeatureStatus.java
└─ FeatureNotFoundException.java
```

```text
feature/
└─ model/
   ├─ Feature.java
   ├─ FeatureStatus.java
   ├─ FeatureCalculation.java
   ├─ FeatureCommand.java
   └─ FeatureRow.java
```

### 패키지 구조 베스트

```text
feature/
├─ api/
│  ├─ FeatureController.java
│  ├─ request/
│  │  └─ CreateFeatureRequest.java
│  └─ response/
│     └─ FeatureResponse.java
├─ service/
│  ├─ FeatureService.java
│  ├─ model/
│  │  ├─ CreateFeatureCommand.java
│  │  └─ FeatureExecutionResult.java
│  └─ impl/
│     └─ FeatureServiceImpl.java
├─ dao/
│  ├─ FeatureDao.java
│  ├─ projection/
│  │  └─ FeatureSummary.java
│  └─ jpa/
│     └─ FeatureDaoJpa.java
├─ entity/
│  └─ Feature.java
├─ domain/
│  ├─ FeatureCalculation.java
│  └─ FeatureStatus.java
└─ exception/
   ├─ FeatureNotFoundException.java
   └─ FeatureExceptionHandler.java
```

기본 선택인 JPA를 사용하면 저장 기술 구현을 `dao/jpa`에 둡니다. Spring Data interface를 별도 구현 없이 직접 저장 계약으로 사용하는 경우에는 `dao`에 두고 빈 `dao/jpa` 계층을 만들지 않습니다.

`entity`, `domain`, `service/model`, `dao/projection`은 이름이 아니라 책임으로 판정합니다.

- `@Entity`가 붙고 DB row의 식별·연관관계와 lifecycle을 표현하면 `entity`입니다.
- persistence annotation 없이 여러 use-case에서 재사용되는 금액, 상태, 정책과 계산 결과라면 `domain`입니다.
- 한 Service 호출을 시작하거나 그 실행 결과만 전달하면 `service/model`입니다.
- 조회 query의 column 조합과 cardinality에 종속되면 `dao/projection`입니다.
- 외부 JSON 계약에 종속되면 `api/request` 또는 `api/response`입니다.
- `entity` 패키지가 영속성 책임을 드러내므로 모든 클래스에 `Entity` suffix를 기계적으로 붙이지 않습니다. 기존 명명 규칙이나 실제 이름 충돌이 있을 때만 suffix를 선택합니다.
- `domain` 클래스에는 `DomainModel`, `Data`, `Info` 같은 포괄 이름보다 `FeatureStatus`, `FeatureCalculation`처럼 업무 의미를 붙입니다. use-case 입출력은 `Command`·`Result`, query projection은 조회 목적이 드러나는 이름을 사용합니다.

## 2) 아키텍처와 설계 판단

### 2.1) 설계 입력

- 기능 요구사항: 핵심 use-case, 행위자·권한과 도메인 규칙
- 비기능 요구사항: 성능, 보안, 확장성과 관측성
- 영향 범위: 모듈, API, 데이터, batch와 외부 연동
- 데이터 흐름: 입력, 저장, 조회, event와 실패 경로
- 테스트 전략: 단위, 통합, E2E와 회귀 지점

### 2.2) 리뷰 순서

1. 현재 구조와 기존 패턴 파악
2. 요구사항과 제약 명확화
3. 대안과 trade-off 비교
4. 결정과 근거를 요구사항, 작업 문서 또는 ADR에 고정

### 2.3) 계층 책임과 의존성

- API: 요청 parsing, 인증·인가 연계와 response mapping
- Application·Service: use-case orchestration과 transaction 경계
- Domain: 업무 규칙, 상태 전이와 불변식
- Infraitem: DB, cache, messaging과 외부 API 연동
- 의존성은 상위 정책에서 하위 구현으로 단방향을 유지하고 순환 참조와 계층 우회를 피합니다.
- 회사 표준 계층을 사용하는 경우 `Controller -> Service -> DAO -> Model` 흐름을 기본으로 합니다.
- Controller는 최소 입력 검증과 응답 mapping에 집중하고 업무 로직을 두지 않습니다.
- DAO는 조회·저장과 기술 예외의 저장소 계약 변환에 집중하고 업무 상태 판단은 service에 둡니다.
- JDBC update count 0은 count로 반환하고 service가 업무 의미에 맞는 예외를 결정합니다.

### 2.4) use-case orchestration 기준 순서

1. 처리 시각, 요청자와 정책 버전 확정
2. DB 접근 없이 가능한 요청 검증
3. 상위 대상 조회와 존재·상태·권한 검증
4. 정책과 기준 데이터 조회
5. 하위 목록, 상세와 집계 조회
6. 종속 데이터와 정책 조건 검증
7. 옵션과 분기 처리
8. 비용, 수량과 상태 반영
9. 결과와 후속 작업 생성
10. 변경 데이터 저장
11. 감사·운영 로그 기록
12. 응답 생성

모든 기능을 이 순서에 억지로 맞추지 않고 transaction과 데이터 의존성에 따라 조정합니다. 앞선 gate가 실패하면 비용이 큰 하위 조회와 외부 호출을 수행하지 않습니다.

### 2.5) trade-off와 위험

- Pros, Cons, Alternatives와 Decision 근거를 남깁니다.
- 복잡도, 운영 비용과 성능 비용을 기대 이득과 함께 비교합니다.
- 기존 API, 데이터, batch와 소비자 호환성을 유지하거나 깨지는 지점을 명시합니다.
- 운영 영향이 있으면 rollout 순서, rollback point와 monitoring 신호를 함께 정합니다.

간단한 ADR 형식:

```markdown
# ADR-XXX: 제목

## Context
결정이 필요한 배경과 제약

## Decision
최종 선택과 이유

## Alternatives
검토한 대안과 배제 이유

## Consequences
장단점과 후속 작업
```

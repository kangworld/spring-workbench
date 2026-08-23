# 테스트와 검증

## 1) 기본 원칙

- 테스트는 구현 세부가 아니라 요구사항 계약, 통합 경계와 회귀 위험을 고정합니다.
- 테스트 범위는 변경 코드 실행 경로와 실제 사용자 흐름을 함께 기준으로 잡습니다.
- 핵심 메서드의 단위 테스트와 핵심 service·DAO 통합 테스트를 우선합니다.
- 전체 애플리케이션 기동 테스트는 실제 기동 검증이 목적일 때만 사용합니다.
- 테스트는 독립적이고 재현 가능하며 결정적으로 동작해야 합니다.
- 하나의 테스트는 하나의 목적을 검증하고 실패 이유가 명확해야 합니다.
- 버그 수정으로 기존 동작이 깨진 것이 확인되면 같은 시나리오의 회귀 테스트를 추가합니다.
- 테스트 실패는 `현재 변경`, `기존 실패`, `판단 불가`로 구분합니다.
- 증거가 부족하면 성공으로 낙관하지 않습니다.

## 2) 범위 선택

- 단위 테스트: 순수 로직, 계산, 변환, 검증 함수와 독립 helper
- DAO 통합 테스트: SQL, key·row mapping, generated key, JSON과 실제 DB 제약
- service 통합 테스트: 실제 bean, proxy, transaction, advisor와 여러 저장 책임
- E2E: 인증, 결제와 핵심 업무 흐름처럼 중요한 사용자 경계

mock이 실제 실패를 숨길 수 있는 통합 경로와 데이터 정합성 위험이 있는 흐름은 통합 또는 E2E를 우선합니다.

## 3) 경계값과 실패 경로

- null, empty, 최소값, 최대값, 잘못된 타입과 포맷을 검증합니다.
- 권한 실패, 유효하지 않은 상태 전이, 중복 요청, 멱등성과 동시성 충돌을 검증합니다.
- 수치·용량·시간 임계값은 정확한 성공 경계와 바로 바깥 실패 경계를 짝으로 검증합니다.
- 임계값에서 먼 실패 사례나 회귀 사례만으로 경계값 검증을 대신하지 않습니다.
- 테스트 이름, JavaDoc과 fixture에 판정 입력과 기대 결과가 드러나야 합니다.

예를 들어 `소비 15 = 공급 15` 성공과 `소비 15 > 공급 14` 실패를 별도 테스트로 고정합니다.

## 4) 실제 조립 우선

- Spring component인 service와 DAO를 테스트에서 `new`로 수동 생성하지 않습니다.
- 실제 bean을 주입해 proxy, transaction, advisor와 mapper 설정을 함께 검증합니다.
- 범용 수동 조립 객체를 새로 만들기 전에 기존 Spring test context를 확장합니다.
- repository·DAO와 영속 흐름은 가능한 한 현재 적용 기술의 실제 구현과 local DB를 사용합니다. 신규 기술 선택은 JPA를 기본으로 하되 기존 JDBC·MyBatis·R2DBC 영역은 해당 구현으로 검증합니다.
- mock은 외부 시스템, 장애·특정 반환 재현과 상위 계층 위임 검증처럼 명확한 경계에만 둡니다.
- mock DAO만으로 service를 통과시키면 SQL, key mapping, transaction과 proxy 문제가 가려질 수 있음을 인식합니다.
- 전체 context가 필요하지 않으면 `@ContextConfiguration`과 필요한 import로 최소 context를 구성합니다.

워스트:

```java
@Test
void testRollbackForEveryRuntimeException() {
    // 실제 실패 계약과 관계없는 일반 예외까지 중복 검증합니다.
}
```

베스트:

```java
@DataJpaTest
@Transactional
class StoragePolicyRepositoryTest {

    @Test
    void testWhenInsertDuplicateTargetThenRejectByUniqueKey() {
        // 확정된 DB 중복 계약을 실제 DB에서 검증합니다.
    }
}
```

## 5) 테스트 데이터와 공개 계약

- 테스트 코드에 `SELECT`, `INSERT`, `UPDATE`, `DELETE` 네이티브 SQL을 직접 작성하지 않습니다.
- 상태 생성과 조회는 실제 DAO, repository와 service의 공개 계약을 사용합니다.
- 테스트 데이터는 test transaction rollback으로 정리합니다.
- builder는 객체 생성만 담당하고 DB 저장은 테스트 본문에서 실제 DAO로 수행합니다.
- 결과에 영향을 주는 값과 nullable 값은 호출부에서 명시하고 공유 singleton fixture의 기본값으로 숨기지 않습니다.
- 쓰기 전용 로그 DAO의 service 테스트는 로그 테이블을 직접 조회하지 않습니다.
- 영속성 model과 mapping은 repository·DAO 테스트가 소유하고 service 테스트는 상태 변경과 transaction 결과를 검증합니다.
- 테스트 편의를 위해 운영 DAO에 조회·삭제 API를 추가하지 않습니다.
- DB mapping 모델의 기본 생성자와 mapping 경로를 보존합니다.

## 6) 설정과 모듈 연동

- override 테스트는 실제 모듈 설정을 사용하고 가짜 속성을 추가하지 않습니다.
- 재정의한 실제 값과 재정의하지 않은 module default를 함께 검증합니다.
- 설정 파일 이름과 위치, PropertySource·Config Data loading과 bean 생성 결과를 실제 context에서 확인합니다.
- 공통 모듈 변경 시 모듈 자체 테스트와 소비 서버 테스트를 모두 실행합니다.
- 전체 context 실패를 우회하려고 test resources에 main 설정을 중복하지 않습니다.
- 실패 원인과 실제 설정 경로를 먼저 확인합니다.
- 테스트별 fixture 설정은 소유 테스트에서만 import하고 운영 component scan에 섞지 않습니다.
- 테스트 통과만을 위한 placeholder bean이나 전역 설정을 추가하지 않습니다.

### 공통 service context

- service 통합 테스트는 실제 controller, service, advisor와 운영 설정을 조립해 wiring 오류를 함께 검증합니다.
- lazy initialization으로 조립 오류를 숨기지 않습니다.
- 공통 test annotation과 bootstrap을 사용하고 domain마다 scan package나 정규식을 추가하지 않습니다.
- bootstrap은 운영 애플리케이션 자동 탐색과 충돌하지 않는 명시적 test 시작점으로 둡니다.
- test 전용 configuration은 운영 component scan에서 제외하고 소유 테스트가 명시적으로 import합니다.
- 운영 bean을 테스트마다 다시 import하지 않고 외부 시스템이나 의도적으로 대체하는 경계만 mock으로 선언합니다.

## 7) 통합 경계별 핵심 검증

- 인증·보안: 정상, 만료, 변조, 재사용, 상태 불일치와 정확한 결과 코드
- API 계약: 성공·실패 구조, null·빈 컬렉션 정책, serialization과 문서화 설정
- 사용자 context: 인증 주체 해석, 존재하지 않는 데이터, controller와 service 책임
- transaction·동시성: advisor 순서, 활성 transaction, row lock, 중첩 실행과 rollback
- 영속·로그: 수치 한계, 업무 예외, 실제 DAO, 여러 DB 책임과 부분 실패 위험
- 상태 동기화: 처리 cursor, revision, no-op, 응답과 소비자 상태의 일치

## 8) DB 테스트 자원

- 여러 DB를 함께 쓰는 테스트는 각각의 pool과 transaction manager를 실제 구성합니다.
- 로컬 DB에 필요한 schema나 table이 없으면 테스트를 생략하지 않고 확정 DDL을 기준으로 먼저 구성합니다.
- 현재 범위의 DDL만 적용하고 `SHOW CREATE TABLE`과 인덱스를 대조합니다.
- 존재하지 않는 table을 과거 fixture나 Java 모델만 보고 임의 생성하지 않습니다.
- 소비 서버가 실제 사용하는 datasource와 계정으로 검증합니다.
- 범위 밖 table은 확정 스키마 근거가 있을 때만 구성하고 그렇지 않으면 관련 테스트를 분리해 결과를 기록합니다.
- connection 사용량 문제는 테스트 전용 pool 크기처럼 범위가 좁은 설정으로 해결합니다.
- context cache 전역 변경처럼 다른 테스트 전체에 영향을 주는 우회를 피합니다.
- 정리 순서와 고정 ID가 기존 테스트와 충돌하지 않는지 확인합니다.

## 9) 작성 스타일

- Given·When·Then 또는 Arrange·Act·Assert 구조를 사용합니다.
- 테스트 메서드 JavaDoc에 검증하는 업무 규칙과 실패 시 의미를 설명합니다.
- Given·When·Then을 사용하는 경우 각 구간에 `// given`, `// when`, `// then` 주석을 작성합니다.
- 각 단계 주석은 구간 이름만 반복하지 않고 준비 조건, 실행 행위와 검증 의도를 업무 의미로 설명합니다.
- 단언과 메시지는 실패 원인이 바로 보이게 작성합니다.
- 리플렉션 주입보다 생성자나 테스트 프레임워크 주입을 우선합니다.
- 파일명은 대상 클래스명과 `Test`를 조합합니다.
- 메서드명은 프로젝트 규칙을 따르되 조건과 기대 결과를 드러냅니다.
- 반복문 하나로 많은 사례를 한꺼번에 검증하지 않습니다.
- 시간, random과 외부 상태는 제어 가능한 방식으로 고정합니다.
- timing 의존 코드는 조건 기반 대기를 우선하고 sleep은 마지막 수단으로 사용합니다.

```java
/**
 * 가게 지급액 계산 시 가게 부담 비용과 수수료가 모두 차감되는지 검증한다.
 */
@Test
void whenCalculateSettlement_thenSubtractStoreBurdenAmounts() {
    // given: 상품/옵션 매출과 가게 부담 쿠폰, 배달비, PG 수수료, 중개수수료율을 포함한 정산 원천 데이터를 준비한다.
    OrderSettlementSource source = new OrderSettlementSource(
            1L,
            10L,
            new BigDecimal("10000.00"),
            new BigDecimal("2000.00"),
            new BigDecimal("1000.00"),
            new BigDecimal("500.00"),
            new BigDecimal("3000.00"),
            new BigDecimal("900.00"),
            new BigDecimal("2100.00"),
            new BigDecimal("300.00"),
            new BigDecimal("0.10"),
            new BigDecimal("0.10"));

    // when: 주문 정산 원천 데이터를 기준으로 가게 지급액을 계산한다.
    OrderSettlementResult result = calculator.calculate(source);

    // then: 상품/옵션 매출에서 가게 부담 비용과 수수료, 부가세를 차감한 금액을 지급액으로 검증한다.
    assertThat(result.payoutAmount()).isEqualByComparingTo("10080.00");
}
```

## 10) 검증 증거

완료 보고에는 실행한 명령과 결과를 정확히 남깁니다.

- 관련 테스트
- 영향 영역 회귀 테스트
- compile 또는 test-compile
- 위험에 비례한 전체 테스트
- dependency tree 또는 애플리케이션 기동 확인
- 로컬 DB·API 수동 검증 결과와 환경
- 실행하지 못한 검증과 이유

테스트가 통과하지 않았거나 실행하지 못했으면 성공으로 표현하지 않습니다.

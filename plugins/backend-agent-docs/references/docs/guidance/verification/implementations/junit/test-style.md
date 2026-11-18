# JUnit 테스트 작성 기준

[공통 테스트 기준](../../common/testing.md)과 [Java 코딩 기준](../../../development/implementations/java/coding-conventions.md)을 함께 적용합니다.

- 테스트 메서드 JavaDoc에 검증하는 업무 규칙과 실패 시 의미를 설명합니다.
- Given·When·Then을 사용하는 경우 각 구간에 `// given`, `// when`, `// then` 주석을 작성합니다.
- 각 단계 주석은 구간 이름만 반복하지 않고 준비 조건, 실행 행위와 검증 의도를 업무 의미로 설명합니다.
- 리플렉션 주입보다 생성자나 테스트 프레임워크 주입을 우선합니다.
- 파일명은 대상 클래스명과 `Test`를 조합합니다.
- 실제 실패 계약과 관계없는 일반 예외를 반복 검증하는 테스트를 추가하지 않습니다.

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

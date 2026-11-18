# 설정 기준

## 1) 설정 소유권

- 설정값은 실제 소비 코드와 같은 책임 경계가 소유합니다. 이름이 비슷하다는 이유로 공통 설정 파일이나 임의의 `config` 패키지에 모으지 않습니다.
- Spring Boot 초기 기동 설정, 프로젝트 공용 설정, 외부 모듈 기본값과 환경별 override의 소유 위치를 구분합니다.
- 같은 key를 여러 파일에 중복 선언하지 않습니다. 기본값과 환경 override의 우선순위를 실제 Config Data·`PropertySource` 로딩 순서로 확인합니다.
- 환경 의존 값과 비밀값은 코드에 넣지 않습니다. 문서에는 key, 형식, 등록 위치와 비밀이 아닌 예시만 남깁니다.
- 사용하지 않는 예시 설정, 추측으로 만든 placeholder key와 테스트 통과용 가짜 값을 추가하지 않습니다.

## 2) 설정 추가 절차

1. 설정을 읽는 실제 consumer와 bean 생성·선택 조건을 찾습니다.
2. prefix, type, default, validation, 환경별 선언 위치와 override 순서를 확인합니다.
3. 동일 이름의 bean이나 설정이 이미 있으면 구현 type과 소비 방식을 함께 대조합니다.
4. 설정이 해결할 수 있는 문제인지 확인합니다. 순환 의존성, 중복 component scan과 잘못된 책임 경계를 설정값으로 가리지 않습니다.
5. 실제 application context에서 property binding, bean 선택과 소비 결과를 검증합니다.

## 3) 타입 안전한 설정

- 여러 곳에서 함께 사용하는 설정 묶음은 `@ConfigurationProperties`와 검증 가능한 type으로 표현합니다.
- 문자열 key를 service와 adapter 곳곳에서 직접 읽지 않습니다.
- duration, size, URL과 enum은 의미 있는 Java type으로 변환하고 단위를 key 또는 type에서 명확히 합니다.
- default가 제품 계약이나 운영 정책이면 코드의 임의 fallback으로 숨기지 않고 권위 있는 설정 위치에 둡니다.
- 필수 설정이 없을 때 안전한 실행이 불가능하면 기동 시 명확히 실패시킵니다.

워스트:

```java
@Value("${payment.retry-count:999}")
private int retryCount;
```

베스트:

```java
@ConfigurationProperties(prefix = "payment")
public record PaymentProperties(
		@Min(0) int retryCount,
		@NotNull Duration timeout) {
}
```

## 4) 조건부 bean과 component scan

- 조건부 bean을 추가할 때 조건 평가 전에 bean 이름이 충돌하지 않는지 확인합니다.
- 같은 API를 제공하는 후보가 여러 개면 실제 MVC·messaging context에서 최종 mapping과 bean이 하나만 남는지 검증합니다.
- test bootstrap과 fixture configuration은 운영 component scan에 섞이지 않게 소유 테스트가 명시적으로 import합니다.
- `@Primary`, bean overriding과 lazy initialization으로 잘못된 조립을 숨기지 않습니다.

## 5) override 검증

- override 테스트에는 실제로 소비되는 유효한 key를 사용합니다.
- 재정의한 값뿐 아니라 재정의하지 않은 module default가 유지되는지도 같은 context에서 검증합니다.
- 설정 파일 이름과 위치, profile 활성화, Config Data·`PropertySource` 로딩, 생성된 bean type과 최종 소비 결과를 확인합니다.
- 전체 context 실패를 피하려고 main 설정을 test resources에 복제하거나 placeholder bean을 만들지 않습니다.

워스트:

```java
@TestPropertySource(properties = "payment.test-mode=true")
class PaymentConfigurationTest {
}
```

베스트:

```java
@TestPropertySource(properties = "payment.timeout=2s")
class PaymentConfigurationTest {

	@Autowired
	private PaymentProperties properties;

	@Test
	void testWhenTimeoutIsOverriddenThenKeepDefaultRetryCount() {
		assertThat(properties.timeout()).isEqualTo(Duration.ofSeconds(2));
		assertThat(properties.retryCount()).isEqualTo(3);
	}
}
```

## 6) 운영 설정 검증

- timeout, retry, backoff, circuit breaker, pool, batch size와 scheduler 주기는 비용·부하·실패 의미를 기준으로 정합니다.
- retry는 멱등성, 중복 처리와 result-unknown 위험을 확인한 뒤 적용합니다.
- 환경별 차이는 배포 문서나 프로젝트 고유 지침에 기록하고 실제 profile별 기동으로 검증합니다.
- credential, token, private key와 webhook URL을 문서·Git·명령 출력·로그에 남기지 않습니다.

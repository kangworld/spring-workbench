# Lombok 적용 기준

[Java 코딩 기준](../java/coding-conventions.md)과 함께 적용합니다.

## 의존성과 생성자 주입

- 이 지침을 적용하는 모든 Java module에는 Lombok을 필수 dependency로 설치합니다.
- Gradle은 main·test source set에 `compileOnly`와 `annotationProcessor`를 구성합니다. Maven은 Lombok dependency와 대상 JDK·compiler plugin에 필요한 annotation processor 설정을 확인합니다.
- Spring component의 필수 의존성은 `final` field와 `@RequiredArgsConstructor`로 constructor injection합니다.
- 단순 의존성 주입만 수행하는 public constructor를 직접 작성하지 않습니다. parameter annotation, constructor visibility·overload 또는 별도 초기화처럼 Lombok으로 같은 계약을 표현할 수 없을 때만 명시적 constructor를 사용하고 이유를 남깁니다.
- 단일 constructor에는 `@Autowired`를 붙이지 않습니다.
- `@Getter`, `@Builder`, `@Slf4j`는 type 책임에 맞게 사용하되 boilerplate를 줄인다는 이유로 mutable setter나 숨은 생성 경로를 늘리지 않습니다.
- JPA entity에는 `@Data`, 무분별한 `@Setter`와 type-level `@Builder`를 사용하지 않습니다.

워스트:

```java
@Service
public class OrderServiceImpl implements OrderService {

	private final OrderDao orderDao;

	public OrderServiceImpl(OrderDao orderDao) {
		this.orderDao = orderDao;
	}
}
```

베스트:

```java
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

	private final OrderDao orderDao;
}
```

## 모델 생성

- setter 조립이 반복되는 DB model은 실제 생성 입력만 받는 constructor-level builder를 우선합니다.
- builder naming은 기본 `builder()`와 `Builder`를 사용하고 불필요한 type-level builder와 전체 field constructor 노출을 피합니다.
- mapper가 요구하는 기본 생성자와 setter는 보존하고 application 신규 row 생성은 builder나 명시 constructor로 모읍니다.
- 생성 입력이 여러 개인 model은 전체 field를 여는 type-level builder보다 생성 입력만 받는 constructor-level `@Builder`를 사용합니다.
- builder 대상 constructor는 외부 입력을 직접 대입하는 데 집중합니다. 상태, 합계와 남은 시간 같은 파생값 계산이나 복잡한 검증 흐름을 constructor 안에 숨기지 않습니다.
- builder 이름은 별도 생성 계약이 없다면 Lombok 기본 `builder()`와 `Builder`를 유지합니다.
- 필수 참조 입력에는 constructor parameter의 `@NonNull`을 사용할 수 있지만 field에 같은 annotation을 중복하지 않습니다.
- 단일 식별자처럼 인자 하나를 그대로 대입하는 생성에는 builder를 만들지 않고 명시적 constructor를 유지합니다.

워스트:

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderRecord {

	private Long id;
	private String orderNumber;
	private OrderStatus status;
	private Instant createdAt;
}
```

베스트:

```java
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class OrderRecord {

	private Long id;
	private String orderNumber;
	private OrderStatus status;
	private Instant createdAt;

	@Builder
	private OrderRecord(@NonNull String orderNumber, OrderStatus status) {
		this.orderNumber = orderNumber;
		this.status = status;
	}
}
```

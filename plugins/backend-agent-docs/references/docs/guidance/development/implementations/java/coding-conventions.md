# Java 코딩 규칙

## 1) 코드 스타일과 주석

### 1.1) 이름과 메서드

- class와 type은 명사, method는 동사를 기반으로 이름 짓습니다.
- 축약어를 줄이고 domain 의미와 업무 단계를 이름에 드러냅니다.
- boolean은 `is`, `can`, `has`처럼 참일 때의 상태나 가능 여부를 표현합니다.
- method는 한 책임에 집중하고 주요 업무 절차가 위에서 아래로 읽히게 구성합니다.
- helper는 업무 흐름을 명확하게 하거나 실제 재사용·독립 테스트 가치가 있을 때만 분리합니다.
- 단순 getter, 한 번의 위임과 한 줄 계산을 helper chain으로 만들지 않습니다.
- 의미가 비슷한 검증, 조회, 상태 변경, 후속 처리와 log method를 가까이 배치합니다.
- 코드 형태만 비슷하고 업무 의미가 다르면 억지로 공통화하지 않습니다.
- 공통화로 임시 객체, 불필요한 순회와 parameter 전달이 늘면 분리 구현을 유지합니다.

### 1.2) formatting

- product code에는 `var` 대신 명시 type을 사용합니다.
- 본문이 한 문장인 `if`, `for`, `while`에는 중괄호를 사용하지 않습니다.
- 본문이 둘 이상이거나 `else`가 있거나 중첩으로 오해할 여지가 있으면 중괄호를 사용합니다.
- indentation과 line wrapping은 대상 프로젝트 formatter를 따릅니다.
- collection의 filter, transform과 aggregation은 외부 상태를 누적하는 반복문보다 stream을 우선합니다.
- cursor 변경, 순서별 예외와 상태 전이가 핵심이면 일반 반복문을 사용합니다.
- 의미 없는 대량 formatting 변경을 피합니다.
- 조회, 분류, 계산, 상태 변경과 저장처럼 논리 단계가 달라지면 빈 줄로 구분합니다.
- 짧은 method나 조건문을 한 줄로 압축하지 않습니다.
- 앞에 실행문이 있으면 return 앞에 빈 줄을 두되 한 줄 method와 guard clause에는 불필요한 빈 줄을 만들지 않습니다.
- class와 interface 선언 직후의 빈 줄 등 세부 배치는 프로젝트의 기존 style과 formatter를 우선합니다.

### 1.3) Lombok

Java 모듈에 Lombok을 적용하거나 관련 코드를 수정할 때 [Lombok 지침](../lombok/usage.md)을 확인합니다.

### 1.4) 주석

- 일반 코드와 테스트 코드의 필요한 주석은 필수입니다.
- 주석은 기본적으로 한국어로 작성하되 대상 프로젝트에 별도 언어 규칙이 있으면 이를 우선합니다.
- 코드가 무엇을 하는지 번역하지 않고 의도, 기준, 제약과 실패 위험을 설명합니다.
- service와 핵심 로직의 의미 단위에는 사람이 이해할 수 있는 짧은 문장으로 기준과 이유를 남깁니다.
- 핵심 로직에는 날짜·시간, 금액·수량·확률, 상태 전이, 정렬·배치·grouping, 검증 분기, 외부 연동, 재시도·중복 방지·lock과 운영 조건을 포함합니다.
- 조회, 검증, 계산, 상태 변경, 저장과 후속 호출 등 논리 단계가 달라지면 다음 묶음의 주석 필요성을 확인합니다.
- 주석 앞에 일반 코드가 있으면 한 줄을 비웁니다.
- label형 짧은 `//` 주석에는 마침표를 붙이지 않습니다.
- class와 interface 선언 바로 위에는 `//`, `/* ... */`, JavaDoc을 포함한 상단 주석을 작성하지 않습니다. 역할과 책임은 이름, package와 협력 관계로 드러냅니다.
- record와 enum은 공개 계약이나 값의 의미가 이름만으로 충분하지 않을 때 JavaDoc을 작성합니다.
- 공개 domain field와 enum 상수에는 값의 의미를 설명합니다.
- record component는 record JavaDoc의 `@param`으로 설명합니다.
- TODO에는 맥락과 후속 action을 함께 기록합니다.
- 의미가 달라지면 주석을 즉시 수정하고 완료 전에 누락·낡은 주석을 점검합니다.

#### 주석 품질 검증 기준

- 변경한 Java 파일은 모두 직접 다시 읽고 주석의 누락과 코드 불일치를 확인합니다.
- 의미 있는 업무 로직에는 주석을 작성합니다. 주석은 코드의 동작을 그대로 풀어 쓰지 않고, 업무 조건, 판단 근거, 처리 순서의 이유, 트랜잭션·멱등성·동시성 제약과 실패 시 영향을 설명합니다.
- 금액·수량 계산과 경계값, 검증 분기와 작업 생략 조건, 상태 전이, 조회·저장·외부 호출 순서, 트랜잭션과 롤백 범위, 멱등키 생성·재사용과 중복 처리, 잠금·경합·재시도, 예외를 특정 응답으로 변환하는 이유는 코드와 이름만으로 충분히 드러나지 않을 때 반드시 주석으로 남깁니다.
- 일반적인 애플리케이션 기동, 단순 대입·위임·변환·반환처럼 코드 자체로 의미가 분명한 부분에는 주석을 붙이지 않습니다. 모든 줄에 주석을 달거나, 주석이 필요하다는 이유만으로 처리 단계를 기계적으로 설명하지 않습니다.
- 주석을 검토할 때는 “왜 필요한가?”에 답하는 주석이 빠졌는지 확인하고, “무엇을 실행하는가?”만 반복하는 주석은 제거합니다.
- 모든 `@Test` 메서드에는 검증하는 업무 규칙과 실패 의미를 설명하는 JavaDoc을 작성합니다.
- 테스트 주석은 특이한 준비 조건, 장애 주입 방법, 단언만으로 드러나지 않는 실패 의미를 설명합니다. 테스트 코드에서 바로 알 수 있는 준비·호출·검증 절차는 주석으로 반복하지 않습니다.
- 클래스·인터페이스 선언 바로 위에는 설명 주석이나 JavaDoc을 작성하지 않습니다.

### 1.5) 구성, 운영, 예외와 보안

- 환경 의존 설정은 코드와 분리하고 default와 override 방식을 명확히 합니다.
- 외부 연동 timeout, retry와 circuit breaker는 운영 기준으로 정합니다.
- batch와 scheduler는 재실행 안전성, lock, retry와 장애 복구 절차를 갖춥니다.
- 장애 수정은 재현 조건, 원인 가설과 증거를 확보한 뒤 최소 수정으로 반영합니다.
- 동일 증상의 수정 시도가 세 번 실패하면 땜질을 멈추고 구조·설계 위험으로 올립니다.
- domain exception과 infraitem exception을 구분합니다.
- 사용자 노출 message와 내부 log message를 분리합니다.
- log에는 request ID와 domain key 등 최소 추적 문맥만 남기고 개인정보와 비밀값을 기록하지 않습니다.
- 입력의 길이, 형식, 범위와 허용 값을 server에서 검증합니다.
- 인증·인가 실패와 업무 검증 실패를 구분합니다.
- 민감정보는 저장, 전송과 logging 전 과정에서 최소 수집합니다.

## 2) 엔티티·DTO·값 객체 모델링

### 2.1) 도출과 소유 경계

- 업무 문서, 화면과 정책에서 명사를 추출해 실체·master와 process·state 후보를 구분합니다.
- 상태 전이를 일으키는 행위는 entity가 아니라 domain·service logic에 둡니다.
- 각 entity의 생성·변경 주체와 책임 module을 명확히 합니다.
- 다른 domain과 공유하는 값은 value object나 reference entity로 분리할지 검토합니다.
- 같은 개념을 domain마다 중복 정의하지 않습니다.
- read pattern이 잦은 단위와 함께 변경되는 값을 같은 aggregate로 묶습니다.
- 독립 조회가 필요한 값은 별도 entity로 분리합니다.
- write는 적고 read가 많은 master는 cache와 version 관리 가능성을 고려합니다.

### 2.2) key, state와 history

- business key와 surrogate key를 구분합니다.
- natural key가 바뀔 수 있으면 PK로 사용하지 않습니다.
- composite key는 실제 access pattern과 unique 조건을 기준으로 결정합니다.
- 여러 곳에서 공유하는 composite identifier는 `*Key` value object로 표현합니다.
- 여러 계층에서 공유하는 번호 대역, 최솟값과 최댓값은 개별 service private 상수가 아니라 domain `*Constants`에 둡니다.
- 여러 use-case가 공유하는 확정 식별자는 domain 상수로 이름을 부여하고 문자열을 반복 hardcoding하지 않습니다.
- 상수로 추출할 수 있다는 이유만으로 계약에 없는 상한과 검증을 만들지 않습니다.
- 실제 계약에 존재하는 상태 판정과 전이만 model의 의도 있는 method로 캡슐화합니다.
- state, policy와 history를 분리합니다.
- 상태 전이가 잦고 이력이 필요한 데이터는 log entity로 분리합니다.
- 정책 version이 중요하면 적용 시점과 version을 함께 저장합니다.

### 2.3) DTO·StatusDTO와 mapping

- DB mapping model은 프로젝트의 DTO·StatusDTO와 row mapper 규칙을 따릅니다.
- DB column과 field는 snake_case·camelCase convention으로 일관되게 mapping합니다.
- column alias와 result mapping을 명시해 모호성을 줄입니다.
- legacy column명이 다르면 annotation이나 mapper 설정으로 차이를 흡수합니다.
- status와 flag는 가능한 한 enum으로 표현합니다.
- nullable boolean보다 의미 있는 상태 enum을 우선 검토합니다.
- DB value와 enum mapping 규칙을 문서화하고 알 수 없는 값의 처리 방식을 정합니다.
- JSON·resource serialization 대상은 프로젝트 ObjectMapper와 실제 consumer contract를 확인합니다.
- persistence에 필요 없는 계산 field는 non-mapping 대상으로 분리합니다.

### 2.4) 생성과 불변 값

- 생성 후 값이 바뀌지 않는 request, response, result와 value object는 Java record를 우선 검토합니다.
- 기본 생성자와 setter mapping이 필요한 entity와 기존 DTO·StatusDTO model을 무리하게 record로 바꾸지 않습니다.
- DB JSON 안의 불변 value object는 실제 운영 직렬화 도구의 왕복 변환으로 검증합니다.
- derived state와 계산값은 호출 service가 확정해 명시적으로 전달합니다.
- 기존 public constructor, getter와 setter compatibility를 유지합니다.
- 생성 후 불변 모델의 생성 입력과 매퍼 전용 생성 경로는 구분합니다. Lombok을 쓴다면 [모델 생성 기준](../lombok/usage.md#모델-생성)을 따릅니다.

### 2.5) 이름과 반환 형태

- 단건 조회는 `get`, 목록 조회는 `list`를 사용합니다.
- 행위 이름은 domain 의미를 드러내고 구현 절차를 길게 나열하지 않습니다.
- 생성 대상과 의미에 따라 `create`, `grant`, `register`, `issue`처럼 구체적인 동사를 선택합니다.
- 시각 suffix와 시간 단위는 프로젝트 convention 하나를 일관되게 사용합니다.
- `data`, `configured`, `result`보다 실제 값의 의미를 드러내는 이름을 사용합니다.

### 2.6) 운영·로그 모델

- admin model에는 식별 code, 노출명, 정렬 순서, 사용 여부와 audit field를 일관되게 둡니다.
- 삭제보다 비활성화가 필요한 master는 status 기반 soft delete를 사용합니다.
- log DB entity는 data DB entity와 package·schema를 분리합니다.
- log table은 append 중심으로 설계하고 update를 최소화합니다.
- 원본 identifier, event type, 발생 시각과 추적 key를 포함합니다.

## 3) 추가 워스트/베스트 예시

### 3.1) 한 줄 분기와 반복문

워스트:

```java
if (workers.isEmpty()) {
	return;
}

for (OrderAssignee worker : workers) {
	worker.setState(OrderAssigneeState.IDLE);
}
```

베스트:

```java
// 빈 목록 재호출은 상태 변경 없이 끝냅니다.
if (workers.isEmpty())
	return;

// 기존 worker는 다음 배정을 위해 대기 상태로 돌립니다.
for (OrderAssignee worker : workers)
	worker.setState(OrderAssigneeState.IDLE);
```

### 3.2) stream과 반복문 선택

워스트:

```java
List<Integer> existingWorkerNos = new ArrayList<>();
for (OrderAssignee worker : workers)
	existingWorkerNos.add(worker.getWorkerNo());
```

베스트:

```java
// 이후 번호 비교에 필요한 값만 불변 목록으로 만듭니다.
List<Integer> existingWorkerNos = workers.stream()
		.map(OrderAssignee::getWorkerNo)
		.toList();
```

### 3.3) 논리 단계 개행

워스트:

```java
List<OrderAssignee> permanentWorkers = orderWorkerDao.listPermanent(orderId);
Set<Integer> existingWorkerNos = permanentWorkers.stream()
		.map(OrderAssignee::getWorkerNo)
		.collect(toSet());
long requiredWorkerCount = targetWorkerCount - existingWorkerNos.size();
```

베스트:

```java
// 현재 보유 수는 영구 worker row만 기준으로 계산합니다.
List<OrderAssignee> permanentWorkers = orderWorkerDao.listPermanent(orderId);

// 비어 있는 영구 번호를 찾기 위해 기존 번호를 집합으로 봅니다.
Set<Integer> existingWorkerNos = permanentWorkers.stream()
		.map(OrderAssignee::getWorkerNo)
		.collect(toSet());

// 이미 목표를 채웠으면 재호출을 no-op으로 끝냅니다.
long requiredWorkerCount = targetWorkerCount - existingWorkerNos.size();
if (requiredWorkerCount <= 0)
	return;
```

### 3.4) return 앞 개행

워스트:

```java
output.setOutputItems(new ArrayList<>());
return output;
```

베스트:

```java
output.setOutputItems(new ArrayList<>());

// 빈 목록을 명시해 output 항목을 null로 남기지 않습니다.
return output;
```

### 3.5) class 선언 다음 개행

워스트:

```java
public class OrderItemActionHandler {
	private final Map<Class<? extends OrderItemAction>, OrderItemActionExecutor> executors;
}
```

베스트:

```java
public class OrderItemActionHandler {

	private final Map<Class<? extends OrderItemAction>, OrderItemActionExecutor> executors;
}
```

### 3.6) class 상단 주석

워스트:

```java
/** 배치 할당 제작 구조물의 슬롯 유형과 현재 active 작업입니다. */
public class OrderBatchAllocationSlot {

	/** idle이면 null입니다. */
	private String outputItemCode;
}
```

베스트:

```java
public class OrderBatchAllocationSlot {

	/**
	 * 현재 작업 완료 시 지급할 출력 토큰 코드입니다.
	 */
	private String outputItemCode;
}
```

### 3.7) 내부 로직 주석

워스트:

```java
// worker 번호를 모읍니다.
Set<Integer> existingWorkerNos = permanentWorkers.stream()
		.map(OrderAssignee::getWorkerNo)
		.collect(toSet());
```

베스트:

```java
// 비어 있는 영구 번호를 찾기 위해 기존 번호를 집합으로 봅니다.
Set<Integer> existingWorkerNos = permanentWorkers.stream()
		.map(OrderAssignee::getWorkerNo)
		.collect(toSet());
```

연속된 여러 문장이 하나의 의미 단위인 경우:

```java
// 새 주문는 생성 시각이 속한 재생성 구간을 최초 처리 기준으로 사용합니다.
DateTime normalProcessedDate = normalPolicy.getRecurrenceSchedule()
		.lastAtOrBefore(effectiveDate);
DateTime specialProcessedDate = specialPolicy.getRecurrenceSchedule()
		.lastAtOrBefore(effectiveDate);
OrderRestrictionState state = createRestrictionState(order.getOrderId(),
		normalProcessedDate, specialProcessedDate);
```

### 3.8) 계약 근거와 검증 소유권

워스트:

```java
GameRule gameRule = gameRuleService.get();
if (gameRule == null || gameRule.getInitialWorkerSlotCount() < 1
		|| gameRule.getInitialWorkerSlotCount() > 99)
	throw new OrderCreationConfigInvalidException();

OrderType orderType = orderTypeDao.get(orderTypeCode);
if (orderType == null || !orderTypeCode.equals(orderType.getOrderTypeCode()))
	throw new OrderCreationConfigInvalidException();

DateTime effectiveDate = createdDate.withMillisOfSecond(0);
```

베스트:

```java
public GameRule get() {
	// 소비자가 같은 범위를 반복 검사하지 않도록 조회 경계에서 메타 계약을 확정합니다.
	GameRule gameRule = gameRuleDao.get();
	validate(gameRule);

	return gameRule;
}

public Order create(int userId, String orderTypeCode, DateTime createdDate) {
	// 조회 계약이 보장한 규칙과 호출자가 전달한 생성 시각을 그대로 사용합니다.
	GameRule gameRule = gameRuleService.get();
	OrderType orderType = orderTypeDao.get(orderTypeCode);

	return createOrder(userId, orderType, gameRule, createdDate);
}
```

### 3.9) 도메인 상수와 상태 캡슐화

워스트:

```java
public class OrderAssigneeServiceImpl {

	private static final int MIN_PERMANENT_WORKER_NO = 1;
	private static final int MAX_PERMANENT_WORKER_NO = 99;
}

private static final long MAX_RUNTIME_ID = 4_294_967_295L;

Order order = orderService.create(userId, "BASIC", createdDate);

if (AuthResultCode.SUCCESS == validationResult.getResultCode())
	useClaims(validationResult.getClaims());
```

베스트:

```java
public final class OrderAssigneeConstants {

	public static final int MIN_PERMANENT_WORKER_NO = 1;
	public static final int MAX_PERMANENT_WORKER_NO = 99;
}

public final class OrderTypeConstants {

	public static final String DEFAULT_ORDER_TYPE_CODE = "STANDARD";
}

Order order = orderService.create(userId,
		OrderTypeConstants.DEFAULT_ORDER_TYPE_CODE, createdDate);

if (validationResult.isSuccess())
	useClaims(validationResult.getClaims());
```

### 3.10) 이름과 반환 형태

워스트:

```java
List<OrderAssignee> getPermanent(int orderId);
void createForDeliveryAreas(Order order, Set<Long> deliveryAreaIds);
void ensureMinimumPermanentWorkerCount(int orderId, int count);

DateTime triggerAt = schedule.nextAfter(baseDate);
Set<Long> configuredDeliveryAreaIds = findDeliveryAreaIds();
```

베스트:

```java
List<OrderAssignee> listPermanent(int orderId);
void grant(Order order, Set<Long> grantedDeliveryAreaIds);
void ensurePermanent(int orderId, int targetCount);

DateTime triggerDate = schedule.nextAfter(baseDate);
Set<Long> uniqueDeliveryAreaIds = findDeliveryAreaIds();
```

### 3.11) 타입별 초기화와 component 분리

워스트:

```java
switch (item.getType()) {
case CASHBACK_CREDIT, POINTS_CREDIT -> applyRevenueEffects(...);
case BATCH_ALLOCATION -> applyExtractionEffects(...);
}

private static final Map<OrderItemType, Class<? extends OrderItemEffect>> EFFECT_TYPES = Map.of(
		CASHBACK_CREDIT, ApRevenueEffect.class,
		POINTS_CREDIT, PointsCreditEffect.class);

```

베스트:

```java
public abstract class AbstractRevenueProductionInitializer<E extends OrderItemEffect>
		implements OrderItemAllocationInitializer {

	@Override
	@Transactional
	public void initialize(...) {
		// 서로 다른 적립 유형이 공유하는 allocation row 생성 순서만 소유합니다.
	}
}

@Component
public class ApRevenueProductionInitializer
		extends AbstractRevenueProductionInitializer<ApRevenueEffect> {

	@Override
	public OrderItemType getOrderItemType() {
		return OrderItemType.CASHBACK_CREDIT;
	}

	@Override
	protected Class<ApRevenueEffect> getEffectType() {
		return ApRevenueEffect.class;
	}
}
```

# 도메인 구현 기준

## 1) 서비스 경계를 설계하는 순서

- 클래스나 계층을 먼저 정하지 않고, 같은 상태를 읽고 변경하는 유스케이스들이 하나의 도메인 책임으로 묶일 수 있는지 먼저 확인합니다. 비슷한 일을 하는 service를 나누기 전에 하나의 service에서 의도 있는 메서드들로 표현할 수 있는지 검토합니다.
- 유스케이스를 분리해야 한다면 공통 조회·조인·검증이 실제로 독립된 도메인 책임인지 확인합니다. 독립된 책임과 재사용 수명주기가 있을 때만 별도 service로 만들고, 단순 데이터 준비는 호출 service의 목적이 드러나는 private 메서드로 둡니다.
- 새로 만든 service가 조회 전달, Map 구성 또는 다른 service 호출 몇 줄만 수행한다면 경계가 너무 얇은지 다시 확인합니다. 이 경우 원래 service와 합치거나 private 메서드로 되돌리는 편을 우선합니다.
- context, plan, wallet 같은 이름으로 로직을 감추지 않습니다. 이런 객체는 이미 준비되거나 확정된 데이터를 보관하는 데 집중하며, DAO/service bean을 받아 조회하거나 자원별 분기·상태 변경·저장을 함께 수행하지 않습니다.
- 공통화로 클래스 수를 늘리는 것보다 각 service의 메인 메서드에서 `데이터 준비 → 판정·계산 → 상태 변경 → 저장`이라는 목적과 호출 흐름이 바로 읽히는 것을 우선합니다. 아직 안정되지 않은 공통 로직은 소량 중복을 허용하고 실제 책임이 확인된 뒤 통합합니다.

## 2) 조회·조인·조립

- 이미 알고 있는 대상 키로 필요한 row만 일괄 조회합니다.
- 현재 유스케이스의 계산·효력 대상이 아닌 row는 키 수집 전에 한 번 제외하고 이후 단계에 섞지 않습니다.
- 조회 결과는 키 Map으로 준비하고, 마지막 단계에서 최종 대상을 조립합니다.
- 조립이 끝난 뒤 계산기·factory·값 객체에는 조회용 Map 전체가 아니라 실제 계산에 필요한 도메인 객체만 전달합니다.
- 순서 순회는 `List`, 키 조회는 `Map`, 여러 값이 하나의 개념을 이루면 전용 값 객체를 사용합니다.

## 3) 메인 흐름과 추상화

- 메인 메서드에서는 유스케이스의 선택·계산·변경·저장 순서가 바로 읽혀야 합니다.
- `data`, `result`, `joinedItems`처럼 과정이나 형태만 말하지 않고, 변수에 들은 값의 의미를 이름으로 표현합니다.
- boolean 메서드는 참일 때의 도메인 상태를 긍정형으로 표현하고, 호출자가 부정 조건의 반대 상태를 다시 추론하지 않게 합니다.
- 중첩 분기나 여러 연산이 한 표현식에 겹쳐 의미를 따라가기 어려우면 조건과 계산 결과를 이름 있는 지역 변수로 먼저 확정합니다.
- 두 분기가 같은 결과의 값 하나만 선택하면 삼항식으로 값을 확정하고 반환은 한 번만 작성합니다.
- 단순 조회 전달·Map 구성·한 번의 위임만 위한 service, context, loader, resolver, plan을 만들지 않습니다.
- 새 클래스는 독립된 도메인 책임과 재사용 수명주기가 있을 때만 분리합니다.
- 이미 한 객체에 모인 값의 사용법은 그 객체의 의도 있는 메서드로 캡슐화합니다.

## 4) 검증과 DB 제약

- specs·DB·도메인 불변식에 있는 검증만 소유 경계에서 한 번 수행합니다.
- 순서가 있는 검증은 앞 조건을 통과한 대상만 다음 조회·bean 주입·계산을 준비하여 실패 이후의 불필요한 작업을 만들지 않습니다.
- 항상 함께 실행되는 검증을 호출 형태별 overload로 반복 분리하지 않고, 유스케이스의 준비·판정 흐름이 한 곳에서 읽히게 구성합니다.
- 중복은 PK·UNIQUE로 막고, 저장 전 전체 목록을 조회해 순회하지 않습니다.
- DB가 보장하지 않는 확정 참조 규칙은 인덱스를 사용하는 단건 조회로 확인합니다.
- 호출자가 이미 확정한 값을 후속 mapper·factory·service에서 다시 검증하지 않습니다.
- specs, DB 제약 또는 실제 도메인 불변식에 근거하지 않은 범위 검증·시각 보정·상태 선검증을 방어 코드라는 이유로 추가하지 않습니다.
- 외부 입력 경계나 핵심 상태 전이에서 확정한 불변식을 후속 service, 로그 factory, mapper에서 반복 검증하지 않습니다. 값 변환만 담당하는 계층은 앞선 경계가 확정한 값을 신뢰합니다.
- 키로 조회한 객체의 키를 다시 비교하지 않습니다. 조회 결과 부재가 현재 유스케이스의 명시적 실패 조건일 때만 부재를 처리합니다.
- 저장 정밀도 때문에 시각을 변환해야 한다면 specs 또는 DB 계약과 변환 경계를 먼저 명시합니다. 같은 `DateTime`을 전달하면 되는 흐름에서 임의로 밀리초를 버리지 않습니다.
- 현실적으로 도달하기 어렵다는 이유만으로 임의 최댓값을 만들지 않습니다. 상한은 실제 저장 타입, 공개 입력 계약 또는 도메인 규칙이 요구할 때만 둡니다.

## 5) 분기, 상태 변경과 로그

- 두 개 이상의 boolean으로 서로 다른 진입 정책을 압축하지 않습니다.
- 단일·일괄·자동 처리처럼 실패·스킵 규칙이 다르면 공개 메서드로 진입점을 구분합니다.
- 분기별로 값이나 실행 여부만 결정할 수 있다면 공통 상태 변경·저장·반환은 분기 밖에서 한 번 수행합니다.
- 타입별 규칙이 도메인 enum의 고정 책임이면 switch를 소비자마다 반복하지 않습니다.
- 로그별로 변경 전 상태와 변경 후 상태 중 무엇을 기록하는지 먼저 확정하고, 필요한 값을 상태 변경 순서에 맡기지 말고 명시적인 스냅샷으로 보관합니다.
- 변경 전 값이 필요한 로그 객체는 모델을 변경하기 전에 생성합니다. DAO insert를 나중에 호출하더라도 factory에 전달한 모델의 당시 값만 기록된다는 점을 기준으로 순서를 정합니다.
- service 테스트는 로그 factory 호출 시점의 필드와 상태 저장 결과를 함께 검증하고, 마지막 저장 실패가 앞선 보상·상태 변경을 부분 성공으로 남기지 않는지 확인합니다.

## 6) 서비스와 협력 객체의 경계

- `Service`는 비즈니스 규칙, 상태 변경과 유스케이스 순서를 소유하는 객체에 사용합니다.
- 도메인 service는 interface로 계약을 노출하고 `*ServiceImpl`이 자기 도메인의 조회·검증·상태 변경과 transaction을 소유합니다.
- 여러 도메인을 잇는 service는 전체 transaction과 호출 순서만 소유합니다. 의존성이 늘면 기술 단계별 helper service가 아니라 실제 상태를 가진 도메인 service로 행위를 옮깁니다.
- `*PlanService`, `*PersistenceService`처럼 기술 단계를 service로 나눠 책임을 흩뜨리지 않습니다. 실제 도메인 유스케이스를 식별할 수 없을 때 임시로 만드는 service는 허용하지 않습니다.
- 내부 도메인 작업을 받아 등록된 전략으로 완료하는 객체는 `Handler`로 명명합니다.
- `Dispatcher`는 command bus나 front controller처럼 서로 다른 종류의 외부 요청을 중앙에서 분배하는 경계에 사용합니다.
- DB singleton 규칙·정책을 조회하고 row 정합성을 보장하는 객체는 다른 전역 규칙과 동일하게 service interface/impl로 표현합니다.
- `Provider`는 프로젝트 내부 도메인 정책 조회가 아니라 외부 SPI에 값을 공급하는 adapter에 사용합니다.
- 단순 handler에 구현 교체 요구가 없으면 interface/impl을 기계적으로 나누지 않습니다.
- action executor는 다형 action을 해석하고 도메인 service에 위임하는 역할만 가집니다.
- 여러 DAO의 조회·생성·보정과 원자성은 action 이름의 executor가 아니라 해당 상태를 소유하는 도메인 service에 둡니다.
- type과 effect class 대응을 정적 Map이나 삼항식에 숨기지 않고 호출 흐름에서 드러냅니다.
- type마다 최초 상태와 effect 계약이 다르면 initializer interface와 type별 구현으로 분리합니다.
- initializer는 최초 runtime 상태만 만들고 이후 보정·시작·정산은 해당 command나 시간 처리 경계에 둡니다.
- type별 계약은 구체 initializer가 소유하고 실제 공통 순서만 추상 class에 둡니다.
- initializer registry는 구현체 등록과 선택만 담당하며 별도 정적 대응표를 중복하지 않습니다.
- 다형 action처럼 구현체 확장이 계약이면 handler와 executor를 사용하고 handler는 routing만 수행합니다.

## 7) 직접적인 제어 흐름과 모델 책임

- 한 메서드가 한 번만 위임하는 `handle`/`getExecutor`, `validate`/`getRequired` 같은 얇은 helper를 연쇄시키지 않습니다.
- 같은 컬렉션을 준비 목록에 넣기 위해 한 번 순회하고 실행하기 위해 다시 순회하지 않습니다. 조회·판정·실행이 한 의미 단위면 한 순회에서 처리합니다.
- 조회 결과 `Map` 여러 개를 helper 인자로 넘기지 않습니다. 결합된 도메인 입력을 먼저 만들고 그 객체를 전달하거나 stream에서 바로 변환합니다.
- 빈 목록이면 저장·cursor 갱신 전체가 불필요한 경우 초기에 반환합니다. 빈 목록 확인을 여러 후속 분기에 반복하지 않습니다.
- 모델이 소유해야 할 ID cursor나 상태 전이는 모델의 의도 있는 메서드로 제어합니다. service가 `get`으로 꺼내 계산한 뒤 `set`으로 되돌려 놓지 않습니다.
- 여러 곳에서 함께 사용하는 복합 식별자는 `Map`의 중첩 키나 반복되는 두 인자 대신 `*Key` 값 객체로 표현합니다.
- 단순 모델의 boilerplate에는 프로젝트 Lombok 패턴을 우선 검토하되 생성 경로는 위의 constructor-level `@Builder` 기준을 따릅니다. ORM·직렬화 요구가 다르면 기존 동작을 실제로 확인한 뒤 최소 annotation만 사용합니다.
- DAO는 저장 방식의 기본 CRUD를 갖춥니다. editor에서 create를 노출하지 않는 정책을 DAO `insert` 부재나 테스트 전용 fixture configuration으로 대신하지 않습니다.

## 8) 트랜잭션과 시간

- DAO `insert`, `update`, `delete`를 직접 수행하거나 여러 상태 변경 행위를 조합하는 public 비즈니스 메서드에는 `@Transactional`을 붙입니다.
- 상위 transaction에서만 호출된다는 현재 호출 관계에 기대지 않고, public 메서드가 단독으로 호출되어도 자신의 원자성을 보장하게 합니다.
- row lock, transaction, aspect/advisor가 함께 동작하면 실행 순서와 활성 transaction 여부를 테스트로 고정합니다.
- 메타 editor는 별도 기능 계약이 없는 한 동시 편집 경합을 처리하지 않습니다. 일반 write transaction만 사용하고 검증을 위한 `lockForUpdate`, editor 간 직렬화, 재시도나 낙관적 lock을 추가하지 않습니다.
- DAO 조회를 그대로 위임하는 단순 카탈로그 조회 service에는 `@Transactional(readOnly = true)`를 붙이지 않습니다. 여러 조회의 일관성, 영속성 context 또는 lock처럼 명확한 transaction 경계가 필요할 때만 근거와 함께 적용합니다.
- 중첩 실행 상태는 실제 수명주기에 필요한 최소 정보만 보관하고 일반화를 위한 상태값을 미리 추가하지 않습니다.
- 처리 cursor, 실제 상태 변경 여부, revision처럼 의미가 다른 값은 하나의 성공 여부로 합치지 않습니다.
- 서버 상태 동기화 정책은 서버 코드만 보지 않고 specs와 실제 소비 클라이언트 흐름을 함께 확인합니다.
- 물리 시간, 저장 시간, 도메인 계산 시간이 서로 다른 정밀도나 역할을 가지면 명시적으로 분리합니다.

## 9) API와 공통 계약

- 인증, 세션, 외부 검증, 도메인 처리처럼 수명주기와 책임이 다른 경계를 한 service에 섞지 않습니다.
- 공통 응답이나 부가 데이터 처리는 기존 모듈의 확장 지점을 우선 사용하고 개별 controller/service에 반복 구현하지 않습니다.
- 성공과 실패 응답은 specs에 정의된 계약을 각각 따릅니다. 편의를 위해 필드 구조를 임의로 통일하지 않습니다.
- 현재 구현되지 않은 후속 피처의 데이터를 가짜 값이나 임시 모델로 먼저 채우지 않습니다.
- error/result code와 직렬화 결과는 이름 규칙을 추정하지 않고 정확한 specs 계약과 실제 ObjectMapper 동작으로 검증합니다.
- 사내 모듈의 역할은 구현 코드의 양이나 현재 직접 호출 여부만으로 판단하지 않습니다. 공통 계약, SPI, 설정 기반 모듈인지 소비 코드와 이력을 확인합니다.
- 공통 모듈이 이미 소유한 계약을 프로젝트 전용 interface나 wrapper로 중복 정의하지 않습니다.
- 초기화, 변경, 로그 기록은 별도 편법 경로를 만들기보다 정상 도메인 처리 흐름을 재사용하는 방향을 우선 검토합니다.
- data/log 등 저장 책임이 다르면 DAO와 실패 위험을 구분하고, 여러 저장소를 묶는 트랜잭션의 보장 범위를 명시합니다.
- specs와 저장/API 계약이 확정되지 않은 후속 영역은 선행 구현에 억지로 결합하지 않고 보류 범위로 남깁니다.

## 10) 워스트/베스트 예시

### 10.1) 조회·조인·조립

워스트:

```java
List<CollectionTarget> targets = productions.stream()
		.map(production -> new CollectionTarget(production,
				policies.stream()
						.filter(policy -> policy.matches(production))
						.findFirst()
						.orElse(null)))
		.toList();
```

베스트:

```java
Map<TargetKey, StoragePolicy> policyByTarget = StoragePolicy.toMap(
		storagePolicyService.listByTargets(targetKeys));

List<CollectionTarget> targets = productions.stream()
		.map(production -> new CollectionTarget(
				production, policyByTarget.get(production.targetKey())))
		.toList();
```

비대상 제외와 조립 워스트:

```java
Map<TargetKey, StoragePolicy> policyByTarget = loadPolicies(productions);

return productions.stream()
		.map(production -> CollectionTarget.from(production, policyByTarget))
		.filter(CollectionTarget::isCollectable)
		.toList();
```

비대상 제외와 조립 베스트:

```java
// 현재 수거 대상만 남겨 이후 조회와 계산에서 상태 분기를 반복하지 않습니다.
List<OrderItemAllocation> collectableProductions = productions.stream()
		.filter(OrderItemAllocation::isCollectable)
		.toList();

// 남은 대상이 참조하는 정책만 조회해 키로 결합합니다.
Map<TargetKey, StoragePolicy> policyByTarget = loadPolicies(collectableProductions);

// 조립이 끝난 객체에는 조회 자료구조가 아니라 실제 정책을 전달합니다.
return collectableProductions.stream()
		.map(production -> CollectionTarget.from(
				production, policyByTarget.get(production.targetKey())))
		.toList();
```

### 10.2) 메인 흐름과 추상화

워스트:

```java
long capAmount = policy.getBaseAmount();
if (storage != null)
	capAmount = levelPolicy.getAmount();

return new Limit(capAmount, currentAmount);
```

베스트:

```java
long capAmount = storage == null
		? policy.getBaseAmount()
		: levelPolicy.getAmount();

return new Limit(capAmount, currentAmount);
```

긍정 상태와 계산 이름 워스트:

```java
if (!orderItem.isCurrentLevelIneffective())
	consume += Math.max(currentLevel.getPowerConsume(), targetLevel.getPowerConsume());
```

긍정 상태와 계산 이름 베스트:

```java
if (orderItem.isUpgrading()) {
	// 활성화 전에는 현재 소비와 목표 소비 중 큰 값을 예약합니다.
	long upgradeConsume = Math.max(
			currentLevel.getPowerConsume(), targetLevel.getPowerConsume());
	consume += upgradeConsume;
}
```

#### 추상화와 캡슐화

- 단순 조회 전달·Map 구성·한 번의 위임만 위한 service, context, loader, resolver, plan을 만들지 않습니다.
- 새 클래스는 독립된 도메인 책임과 재사용 수명주기가 있을 때만 분리합니다.
- 이미 한 객체에 모인 값의 사용법은 그 객체의 의도 있는 메서드로 캡슐화합니다.

워스트:

```java
return target.production().progress(elapsedMillis,
		target.produceMillis(), target.capaorder());
```

베스트:

```java
return target.progress(elapsedMillis);
```

### 10.3) 검증과 DB 제약

워스트:

```java
boolean duplicate = policyDao.list().stream()
		.anyMatch(stored -> stored.hasSameKey(policy));
if (duplicate)
	throw new PolicyInvalidException();
```

베스트:

```sql
UNIQUE KEY `uidx$policy$target` (`target_type`, `target_code`)
```

```java
StoragePolicy storagePolicy = policyDao
		.getByStorageOrderItemCode(storageOrderItemCode);
if (storagePolicy == null)
	throw new PolicyInvalidException();
```

순차 검증 워스트:

```java
beanInjector.autowire(conditions);
for (Condition condition : conditions)
	validate(condition, userId, orderId);
```

순차 검증 베스트:

```java
// 앞 조건을 통과한 경우에만 다음 조건의 의존성을 준비합니다.
for (Condition condition : conditions) {
	beanInjector.autowire(condition);
	validate(condition, userId, orderId);
}
```

검증 흐름 분산 워스트:

```java
validateStart(userId, orderId, items, targetLevel);
validateStart(userId, orderId, items, currentOrderItem, targetLevel);
```

검증 흐름 분산 베스트:

```java
// 시작 조건과 전력은 항상 같은 유스케이스 흐름에서 이어서 검증합니다.
validateConditions(userId, orderId, targetLevel.getRequiredConditions());
validatePower(items, currentLevel, targetLevel);
```

### 10.4) 분기와 공통 후처리

워스트:

```java
collect(targets, true, false);
collect(targets, false, true);
collect(targets, true, true);
```

베스트:

```java
collect(userId, orderId, itemId, effectiveDate);
collectBatch(userId, orderId, itemIds, effectiveDate);
collectForUpgrade(userId, orderId, itemId, effectiveDate);
```

공통 후처리 워스트:

```java
if (collectAmount > 0L) {
	receiveReward(collectAmount);
	production.reset();
	productionDao.update(production);
	return true;
}

if (!production.reset())
	return false;

productionDao.update(production);
return true;
```

공통 후처리 베스트:

```java
if (collectAmount > 0L)
	receiveReward(collectAmount);

boolean changed = production.reset();
if (!changed)
	return false;

productionDao.update(production);
return true;
```

### 10.5) 상태 변경과 로그

워스트:

```java
production.reset();
productionDao.update(production);
productionLogDao.insert(OrderItemAllocationLog.collected(production, collectAmount));
```

베스트:

```java
// 변경 전 진행도를 기록하도록 상태 변경 전에 로그 스냅샷을 만듭니다.
OrderItemAllocationLog collectionLog = OrderItemAllocationLog
		.collected(production, collectAmount);

// 상태와 로그는 같은 transaction에서 함께 저장합니다.
production.reset();
productionDao.update(production);
productionLogDao.insert(collectionLog);
```

### 10.6) 서비스와 협력 객체의 경계

워스트:

```java
public interface OrderItemAllocationService {

	void applyActiveProduction(...);
}

public class OrderItemAllocationServiceImpl implements OrderItemAllocationService {

	private final Map<OrderItemType, OrderItemAllocationInitializer> initializers;
}
```

베스트:

```java
@Component
public class OrderItemAllocationInitializers {

	private final Map<OrderItemType, OrderItemAllocationInitializer> initializers;

	public void initialize(...) {
		// 등록된 production initializer를 선택해 전달합니다.
	}
}

@Component
public class OrderItemActionHandler {

	private final Map<Class<? extends OrderItemAction>, OrderItemActionExecutor> executors;

	public void handle(OrderItem orderItem, List<OrderItemAction> actions) {
		// 등록된 executor로 전달하는 라우팅만 수행합니다.
	}
}
```

유스케이스 책임 분리 워스트:

```java
@Service
public class OrderCreationServiceImpl implements OrderCreationService {

	private final OrderTypeDeliveryAreaDao zoneDao;
	private final OrderSlotDao tileDao;
	private final OrderItemDao itemDao;
	private final OrderRestrictionDao restrictionDao;

	public Order create(...) {
		// 주문 생성 service가 모든 하위 도메인의 조회와 저장을 직접 수행합니다.
		...
	}
}
```

유스케이스 책임 분리 베스트:

```java
@Service
public class OrderCreationServiceImpl implements OrderCreationService {

	private final OrderDeliveryAreaService orderDeliveryAreaService;
	private final OrderItemCreationService orderItemCreationService;
	private final OrderRestrictionService orderRestrictionService;

	@Transactional
	public Order create(...) {
		// 생성 transaction의 기준이 되는 Order root를 먼저 저장합니다.
		Order order = insertOrder(...);

		// 존을 지급한 뒤 서로 독립된 배치 유스케이스를 순서대로 연결합니다.
		Set<Long> grantedDeliveryAreaIds = orderDeliveryAreaService.grantInitial(order);
		orderItemCreationService.create(order, grantedDeliveryAreaIds, createdDate);
		orderRestrictionService.createInitial(order, grantedDeliveryAreaIds);

		return order;
	}
}
```

### 10.7) 직접적인 제어 흐름

워스트:

```java
List<OrderItemActionExecutor> actionExecutors = new ArrayList<>();
for (OrderItemAction action : actions)
	actionExecutors.add(getExecutor(action));

for (int index = 0; index < actions.size(); index++)
	actionExecutors.get(index).execute(orderItem, actions.get(index));
```

베스트:

```java
// 각 action은 executor를 찾은 즉시 같은 순서로 실행합니다.
for (OrderItemAction action : actions) {
	OrderItemActionExecutor executor = executors.get(action.getClass());
	if (executor == null)
		throw new UnsupportedOrderItemActionException();

	executor.execute(orderItem, action);
}
```

### 10.8) 모델 책임

워스트:

```java
long itemId = order.getNextItemId();
order.setNextItemId(itemId + 1);

@JsonCreator
public DailyTimeSchedule(
		@JsonProperty("timeOfDay") String timeOfDay,
		@JsonProperty("timeZone") String timeZone) {
	...
}
```

베스트:

```java
// 다음 ID 발급과 cursor 이동은 Order가 한 동작으로 보장합니다.
long itemId = order.issueOrderItemId();

@Getter
@NoArgsConstructor
@AllArgsConstructor
public abstract class AbstractTimeSchedule implements TimeSchedule {

	protected String timeOfDay;
	protected String timeZone;
}
```

### 10.9) 트랜잭션 경계

워스트:

```java
public void applySlotConfiguration(...) {
	slotDao.insert(slots);
	queueDao.insert(queues);
	outputDao.insert(outputs);
}
```

베스트:

```java
@Transactional
public void applySlotConfiguration(...) {
	slotDao.insert(slots);
	queueDao.insert(queues);
	outputDao.insert(outputs);
}
```

### 10.10) action executor와 도메인 service 경계

워스트:

```java
public void execute(OrderItem orderItem, OrderItemAction action) {
	List<Slot> slots = slotDao.listByOrderItem(...);
	slotDao.insert(...);
	queueDao.insert(...);
	outputDao.insert(...);
}
```

베스트:

```java
public void execute(OrderItem orderItem, OrderItemAction action) {
	ConfigureBatchAllocationAction slotAction = (ConfigureBatchAllocationAction) action;
	batchAllocationService.applySlotConfiguration(orderItem,
			slotAction.getNormalSlotNos(), slotAction.getCombinationSlotNos());
}
```

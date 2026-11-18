# Spring 트랜잭션 기준

[도메인 구현](../../common/domain-implementation.md)과 [영속성 공통 기준](../../../persistence/common/persistence.md)에 정의된 원자성을 Spring에서 보장합니다.

- DAO `insert`, `update`, `delete`를 직접 수행하거나 여러 상태 변경 행위를 조합하는 public 비즈니스 메서드에는 `@Transactional`을 붙입니다.
- row lock, transaction, aspect/advisor가 함께 동작하면 실행 순서와 활성 transaction 여부를 테스트로 고정합니다.
- DAO 조회를 그대로 위임하는 단순 카탈로그 조회 service에는 `@Transactional(readOnly = true)`를 붙이지 않습니다. 여러 조회의 일관성, 영속성 context 또는 lock처럼 명확한 transaction 경계가 필요할 때만 근거와 함께 적용합니다.
- `REQUIRES_NEW`는 원 transaction rollback 뒤에도 감사·실패 상태가 반드시 남아야 하는 등 명시적 목적이 있을 때만 사용한다.
- self-invocation으로 Spring transaction proxy가 적용된다고 가정하지 않는다.

## 여러 저장 작업의 원자성

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

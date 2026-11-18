# R2DBC·Reactive 적용 시

R2DBC 저장소나 리액티브 트랜잭션을 변경할 때 [공통 영속성 기준](../common/persistence.md)과 함께 적용합니다.

- reactive chain 안에서 blocking JDBC, filesystem과 network call을 실행하지 않는다.
- `subscribe()`를 service 내부에서 직접 호출해 transaction·error propagation을 끊지 않는다.
- reactive transaction은 publisher chain 전체에서 유지하고 외부 side effect와 DB commit 순서를 명시한다.
- retry operator는 idempotent operation과 분류된 transient error에만 적용한다.
- backpressure와 대량 row buffering 위험을 검증한다.

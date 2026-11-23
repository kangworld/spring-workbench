# Spring JDBC 구현 기준

Spring JDBC로 작성된 DAO를 변경할 때 [공통 영속성 기준](../common/persistence.md)과 함께 적용합니다.

- SQL text, placeholder, bind 순서, generated key와 RowMapper를 DAO 안에 둔다.
- 사용자·외부 입력을 SQL 문자열에 결합하지 않는다.
- dynamic SQL은 parameter binding을 유지하며 복잡한 문자열 연결보다 프로젝트 helper나 구조화된 builder를 사용한다.
- update·batchUpdate 결과 count를 caller에 반환하고 DAO에서 domain exception을 결정하지 않는다.
- generated key 미반환, 예상하지 않은 row count와 mapping 실패는 저장 계약 위반으로 구분한다.
- batch insert/update는 일부 실패 시 driver 동작과 transaction rollback 범위를 검증한다.
- nullable column의 JDBC getter와 `wasNull`, enum·time mapping을 실제 DB에서 확인한다.
- 변경 경로가 사용하는 실제 Spring JDBC 빈, RowMapper와 테스트 DB를 조립해 파라미터 바인딩, 생성 키, JSON 매핑을 확인한다. 데이터소스가 여러 개면 변경 경로가 올바른 데이터소스와 트랜잭션 매니저에 연결되는지도 검증한다.

비권장 — DAO가 update count 0의 업무 의미를 정해 domain exception을 던진다.

```java
void updateStatus(long id, String expectedStatus, String nextStatus) {
    int updated = jdbcTemplate.update(SQL, nextStatus, id, expectedStatus);
    if (updated == 0) {
        throw new InvalidStateTransitionException(id);
    }
}
```

권장 — DAO는 조건부 변경 결과를 반환하고 Service가 use case의 의미를 결정한다.

```java
int updateStatus(long id, String expectedStatus, String nextStatus) {
    return jdbcTemplate.update(SQL, nextStatus, id, expectedStatus);
}

void changeStatus(long id) {
    int updated = dao.updateStatus(id, "READY", "COMPLETED");
    if (updated == 0) {
        throw new InvalidStateTransitionException(id);
    }
}
```

비권장 — 외부 입력을 SQL text에 직접 결합한다.

```java
String sql = "select * from processing_target where status = '" + requestedStatus + "'";
```

권장 — 값은 placeholder로 bind하고 동적으로 바뀌는 identifier는 허용 목록으로 제한한다.

```java
String sql = "select id, status from processing_target where status = ?";
return jdbcTemplate.query(sql, rowMapper, requestedStatus);
```

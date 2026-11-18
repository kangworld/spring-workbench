# 영속성 구현 기준

## 데이터 접근 기술 기본값

- 이 지침을 적용하는 Spring 프로젝트의 기본 데이터 접근 기술은 Spring Data JPA와 Hibernate입니다.
- 기존 JDBC, MyBatis, R2DBC 구현은 이 기본값만으로 자동 마이그레이션하지 않습니다. 기존 계약, 쿼리 특성, 성능과 운영 위험을 확인해 유지 또는 전환을 별도로 결정합니다.
- 신규 작업에서 JPA 이외의 기술을 선택하면 기존 기술과의 일관성, 대량 처리, 복잡한 SQL, 성능 측정 또는 운영 제약처럼 검증 가능한 이유와 적용 범위를 프로젝트 전용 문서에 기록합니다.
- JPA와 JDBC 기준은 현재 사용 여부와 관계없이 모두 적용 가능한 선택 기준으로 유지합니다. MyBatis와 R2DBC 기준은 실제 사용하거나 도입을 검토할 때 적용합니다.
- 단순한 익숙함이나 예제 코드의 존재만으로 JDBC를 선택하지 않습니다.

## 1. 공통 영속성 원칙

- Service는 project가 정한 repository·DAO 계약에 의존하고 저장 기술의 세부 API를 직접 사용하지 않는다.
- persistence 구현은 query 실행, bind, mapping, generated key, update count와 기술 예외의 저장 계약 변환에 집중한다.
- 조회 결과 없음은 `Optional.empty()`나 빈 목록처럼 계약으로 표현할 수 있지만 update count 0의 domain 의미를 persistence 구현이 임의 예외로 바꾸지 않는다.
- 상태 전이, 중복 요청, 재시도와 경합의 업무 의미는 Service가 판단한다.
- query method는 반환 cardinality와 domain 의미가 이름에서 드러나야 한다.
- API·service test 편의를 위해 production repository·DAO에 전체 조회·삭제 method를 추가하지 않는다.

## 2. 조회와 성능

- 반복 대상에서 단건 key·복합 key 집합을 먼저 만들고 가능한 한 일괄 조회한다.
- 반복문·stream 내부의 repository·DAO 호출로 N+1을 만들지 않는다.
- 조회 결과는 key Map으로 바꿔 memory에서 결합하고 계산에는 필요한 model만 전달한다.
- 여러 상위 ID의 하위 row는 ID마다 조회하지 않고 전체 집합을 받는 query를 사용한다.
- 빈 key 집합은 DB 호출 없이 빈 결과로 끝낸다.
- bind 개수 한도를 넘을 수 있는 대량 입력만 근거 있는 chunk로 나눈다.
- 목록 query에는 습관적으로 정렬을 추가하지 않는다. pagination, cursor, lock 순서, 우선순위와 최초 N건처럼 순서가 기능 계약일 때만 DB 정렬을 사용한다.
- 필요한 column만 읽을 수 있는 projection을 검토하되 mapping과 query 복잡도의 trade-off를 확인한다.
- index는 실제 where, join, ordering과 cardinality를 기준으로 설계하고 이름만 보고 추가하지 않는다.
- query plan과 데이터 규모가 위험한 변경은 대표 데이터로 실행 계획과 처리량을 검증한다.

## 3. 상태 변경, transaction과 lock

- 여러 상태 변경이 함께 성공해야 하는 public use case는 service transaction이 원자성을 소유한다.
- 단순 조회 전달에는 근거 없이 read-only transaction을 붙이지 않는다.
- 외부 HTTP·broker와 긴 계산을 DB transaction 안에 두지 않는다.
- conditional update는 기대 상태·version·소유자 같은 경쟁 조건을 WHERE에 포함하고 update count를 반환한다.
- pessimistic lock은 읽은 값에 따라 다음 상태를 결정하며 동일 row 경쟁을 직렬화해야 할 때만 사용한다.
- optimistic lock은 충돌을 caller가 retry·실패로 처리할 명확한 정책이 있을 때 사용한다.
- 여러 row를 lock하면 획득 순서를 고정해 deadlock 위험을 줄인다.
- `REQUIRES_NEW`는 원 transaction rollback 뒤에도 감사·실패 상태가 반드시 남아야 하는 등 명시적 목적이 있을 때만 사용한다.
- self-invocation으로 Spring transaction proxy가 적용된다고 가정하지 않는다.
- 여러 datasource·database를 묶는 transaction은 실제 원자성 보장 범위와 부분 성공 복구 정책을 기록한다.

비권장:

```java
int updated = repository.updateStatus(targetId, ProcessingStatus.COMPLETED);
if (updated == 0) {
    throw new InvalidStateTransitionException(targetId);
}
```

권장:

```java
int updated = repository.updateStatus(
        targetId,
        ProcessingStatus.READY,
        ProcessingStatus.COMPLETED
);
if (updated == 0) {
    throw new InvalidStateTransitionException(targetId);
}
```

## 4. 검증과 DB 제약

- 식별자와 자연 key 중복은 PK·UNIQUE로 보장한다.
- 필수 관계와 허용 범위는 실제 운영·migration 제약을 고려해 NOT NULL, CHECK, FK 또는 application 검증의 소유권을 명시한다.
- 저장 전에 전체 목록을 읽어 중복을 검사하지 않는다.
- application validation만으로 동시 요청 중복을 막을 수 있다고 가정하지 않는다.
- duplicate exception은 어떤 unique constraint가 발생했는지 구분할 필요가 있는 use case에서만 명시적으로 해석한다.
- 상태 문자열, enum mapping, boolean 표현과 time precision은 Java와 DB에서 일치해야 한다.
- decimal 금액·비율은 precision, scale과 rounding owner를 명시하고 floating-point type으로 바꾸지 않는다.

## 5. Schema 변경의 소유권

- 대상 프로젝트의 schema source는 migration, `schema.sql`, ORM 검증 설정 또는 외부 schema 저장소 중 실제 배포에 권위를 갖는 위치입니다. 작업할 때 권위 있는 경로와 변경 절차를 확인하고, 비표준 소유 경계라면 프로젝트 전용 문서에 기록합니다.
- Java model만 보고 table 계약을 추정하지 않는다.
- column type·length·signed·null·default뿐 아니라 PK, secondary index, UNIQUE, FK, engine, charset·collation과 comment를 확인한다.
- migration은 이전 배포 상태에서 순서대로 적용 가능한가를 검증한다.
- 이미 배포된 migration을 수정하지 않고 새 migration으로 변경한다. 단, 프로젝트가 최종 baseline만 관리하는 명시적 정책이면 그 정책을 따른다.
- baseline을 만들 때는 최초 DDL과 전체 변경 이력을 시간순으로 계산하고 현재 model만 보고 재구성하지 않는다.
- 운영 metadata·policy DML을 schema baseline에 섞지 않는다. bootstrap data의 별도 소유 경계를 확인한다.
- destructive change는 compatibility window, data migration, rollout 순서, rollback과 비용을 함께 계획한다.
- 실제 기준 DB와 Git schema가 다르면 어느 한쪽을 임의로 정답으로 고르지 않고 환경과 적용 기준을 확정한다.


### 최종 baseline DDL 산출

- 신규 환경용 baseline은 중간 `ALTER TABLE` 이력을 나열하지 않고 대상 버전에서 한 번에 생성 가능한 최종 `CREATE TABLE`을 둡니다. 단, 프로젝트가 순차 migration을 권위 있는 배포 방식으로 사용하면 이미 배포된 migration은 유지하고 신규 환경 검증에서 전체 migration 결과를 최종 schema와 대조합니다.
- 최종 DDL은 현재 Java model만 보고 재구성하지 않습니다. 최초 생성 SQL부터 대상 버전까지의 변경 이력, 삭제된 파일, 관련 branch와 실제 소비 애플리케이션의 추가 SQL을 시간순으로 확인합니다.
- column 이름·순서·type·length·signed·NULL·default·PK·secondary index·UNIQUE·FK·engine·charset·collation·comment의 최종값을 계산합니다. index는 model field만으로 드러나지 않으므로 별도 누락 검사를 수행합니다.
- 확인 가능한 기준 DB가 있으면 `SHOW CREATE TABLE`과 index metadata를 대조합니다. Git과 실제 DB가 다르면 미기록 운영 변경으로 보고 적용 환경과 기준을 확정합니다.
- 빈 DB 또는 격리 schema에 적용한 뒤 실제 repository·DAO 저장·조회로 DDL, mapping과 실행 결과를 함께 검증합니다.

### metadata DML과 bootstrap data

- 운영·관리 화면이 소유하는 정책·catalog data를 schema baseline에 임의 `INSERT`하지 않습니다. 해당 data는 운영 업로드, seed migration 또는 별도 bootstrap 절차 중 실제 소유 경계를 따릅니다.
- 애플리케이션 기동 전에 반드시 필요한 bootstrap row와 운영자가 관리하는 정책 data를 구분합니다.
- 기존 DML을 제거할 때는 보이는 `INSERT`라는 이유만으로 삭제하지 않고 최초 계정, 권한, migration marker와 credential 공급 절차를 확인합니다.
- 테스트에 필요한 metadata는 공유 운영 seed에 기대지 않고 테스트 경계에서 실제 repository·DAO로 준비합니다.
## 6. JPA/Hibernate 사용 시 적용 기준

- entity는 persistence lifecycle과 identity를 소유하고 API DTO로 직접 노출하지 않는다.
- 연관관계 fetch 기본값을 명시적으로 확인하고 목록·batch 처리에서 lazy N+1을 막는다.
- fetch join, entity graph와 projection 중 use case에 맞는 최소 조회를 선택한다.
- collection fetch join pagination처럼 framework가 memory pagination으로 바꿀 수 있는 조합을 피한다.
- bulk update/delete는 persistence context를 우회함을 인식하고 clear·refresh 경계를 명시한다.
- 대량 persist는 batch transaction과 `flush/clear`로 persistence context 크기를 제한한다.
- entity 전체 setter와 `@Data`를 피하고 생성·상태 전이 method를 제한한다.
- DB default에 의존하는 값과 entity 초기값이 충돌하지 않는지 실제 insert 결과로 검증한다.
- schema 자동 변경은 운영에서 사용하지 않는다. migration이 schema를 소유하면 JPA는 검증 모드를 사용하고, 외부 schema가 소유하면 그 계약과 entity mapping을 별도로 대조한다.

비권장 — 목록 조회 뒤 lazy association을 순회해 N+1을 숨긴다.

```java
List<String> relatedNames = targets.stream()
        .map(target -> target.getRelatedEntity().getName())
        .toList();
```

권장 — use case에 필요한 값과 대상 집합을 repository query에서 명시한다.

```java
List<TargetSummary> summaries = repository.findSummariesByIdIn(targetIds);
Map<Long, TargetSummary> summaryById = summaries.stream()
        .collect(toMap(TargetSummary::id, identity()));
```

비권장 — entity를 transport model처럼 열어 두고 임의 상태 변경을 허용한다.

```java
@Data
@Entity
class ProcessingTarget {
    private ProcessingStatus status;
}
```

권장 — 생성과 유효한 상태 전이를 의도를 드러내는 method로 제한한다.

```java
@Entity
class ProcessingTarget {
    private ProcessingStatus status;

    void complete() {
        if (!status.canComplete()) {
            throw new IllegalStateException("현재 상태에서는 완료할 수 없습니다.");
        }
        status = ProcessingStatus.COMPLETED;
    }
}
```

## 7. JDBC 사용 시 적용 기준

- SQL text, placeholder, bind 순서, generated key와 RowMapper를 DAO 안에 둔다.
- 사용자·외부 입력을 SQL 문자열에 결합하지 않는다.
- dynamic SQL은 parameter binding을 유지하며 복잡한 문자열 연결보다 프로젝트 helper나 구조화된 builder를 사용한다.
- update·batchUpdate 결과 count를 caller에 반환하고 DAO에서 domain exception을 결정하지 않는다.
- generated key 미반환, 예상하지 않은 row count와 mapping 실패는 저장 계약 위반으로 구분한다.
- batch insert/update는 일부 실패 시 driver 동작과 transaction rollback 범위를 검증한다.
- nullable column의 JDBC getter와 `wasNull`, enum·time mapping을 실제 DB에서 확인한다.

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

## 8. MyBatis 적용 시

- mapper interface와 XML·annotation query의 소유 위치를 기존 관례에 맞춘다.
- resultMap은 column·property mapping과 nested collection 조회를 명시적으로 관리한다.
- `${}` 문자열 치환은 identifier처럼 bind할 수 없는 검증된 값에만 제한하고 일반 입력에는 `#{}`를 사용한다.
- dynamic condition이 빠져 full-table update/delete가 되지 않도록 guard와 test를 둔다.
- mapper session과 Spring transaction 연결을 실제 integration test로 확인한다.

## 9. R2DBC·Reactive 적용 시

- reactive chain 안에서 blocking JDBC, filesystem과 network call을 실행하지 않는다.
- `subscribe()`를 service 내부에서 직접 호출해 transaction·error propagation을 끊지 않는다.
- reactive transaction은 publisher chain 전체에서 유지하고 외부 side effect와 DB commit 순서를 명시한다.
- retry operator는 idempotent operation과 분류된 transient error에만 적용한다.
- backpressure와 대량 row buffering 위험을 검증한다.

## 10. Schema와 DAO 검증

- 빈 database 또는 격리 schema에 전체 migration·schema source를 적용한다.
- 실제 table metadata와 index 목록을 확정 DDL과 대조한다.
- generated key, enum, decimal, time, JSON, nullable과 unique mapping을 실제 persistence test로 검증한다.
- conditional update의 success와 race-lost count를 함께 검증한다.
- transaction rollback과 마지막 저장 실패의 부분 성공 여부를 검증한다.
- production과 다른 embedded DB를 쓰면 dialect, lock, constraint와 time 차이를 별도 실제 DB test로 보완한다.
- 실행 명령은 `testing.md`에 기록한 실제 DB·integration 명령을 사용한다. 별도 task가 없다면 repository·DAO 통합 테스트와 전체 migration 적용 절차를 각각 명시한다.

## 11. Query·Schema 변경 완료 점검

- [ ] query cardinality와 반환 계약이 method 이름에 맞는가.
- [ ] 반복 조회, 불필요한 정렬과 over-fetch가 없는가.
- [ ] transaction owner와 lock 순서가 명확한가.
- [ ] update count 0과 duplicate의 업무 의미를 service가 판단하는가.
- [ ] migration·schema, Java mapping과 실제 DB가 일치하는가.
- [ ] index·unique·FK와 rollback·rollout 영향을 검증했는가.
- [ ] 실행하지 못한 실제 DB 검증과 이유를 남겼는가.

## 12. MySQL schema convention

### 12.1) 적용과 공통 규칙

- 대상 프로젝트의 확정 schema와 운영 compatibility를 우선합니다.
- 예외가 필요하면 이유, 영향 범위, compatibility와 rollback point를 기록합니다.
- table과 column은 `snake_case`, UTF-8은 `utf8mb4`를 기본으로 합니다.
- table comment와 주요 column comment를 작성합니다.
- 금칙어나 예약어는 피하고 약어는 project convention에 맞게 제한합니다.

### 12.2) 이름과 식별자

- 새 table은 단수형 이름을 기본으로 하되 기존 운영 규칙과 충돌하면 기존 규칙을 따릅니다.
- PK는 `{table}_id` 또는 domain identifier pattern을 일관되게 사용합니다.
- boolean 성격 column은 `is_*` 또는 `has_*` 중 project convention 하나를 사용합니다.
- enum·state column은 의미가 드러나는 이름을 사용합니다.
- index는 `idx$...`, unique index는 `uidx$...` 등 project naming pattern을 따릅니다.

### 12.3) type, default와 null

- integer type은 실제 범위와 signed·unsigned 호환성을 확인합니다.
- 금액은 `DECIMAL`을 사용하고 precision·scale을 명시합니다.
- floating point type으로 금액을 저장하지 않습니다.
- 가변 문자열은 `VARCHAR`, 큰 text는 목적에 맞는 TEXT 계열을 사용합니다.
- code·token·hash는 최대 길이와 encoding을 기준으로 길이를 정합니다.
- 의미 없는 default를 넣지 않습니다.
- application과 DB default가 충돌하지 않게 합니다.
- 필수 column은 `NOT NULL`, 미정·미입력·해당 없음이 의미 있게 구분될 때만 `NULL`을 허용합니다.
- JSON 문자열 column은 JSON 유효성, 최대 길이, version compatibility와 serialization 실패 처리를 검토합니다.
- status 값은 코드 상수·enum과 DB 저장값을 일치시키고 신규 상태 추가의 구버전 영향을 확인합니다.

### 12.4) 시간

- 생성 시각은 `crt_date`, 수정 시각은 `upd_date` 등 project convention을 따릅니다.
- `crt_date`는 insert 시 DB server 시간을 사용하고 application에서 임의 주입하지 않습니다.
- `upd_date` 자동 갱신 여부를 명시합니다.
- timezone과 precision 기준을 통일합니다.
- domain 시각과 audit timestamp를 구분합니다.

### 12.5) key, index와 FK

- PK는 업무 식별과 query pattern을 기준으로 결정합니다.
- unique 조건은 중복 방지 규칙을 DB constraint로 보강합니다.
- composite index는 WHERE, JOIN과 ORDER BY 순서를 기준으로 설계합니다.
- selectivity가 낮은 단일 column index는 신중히 사용합니다.
- index 추가 시 write cost와 storage cost를 함께 검토합니다.
- FK 사용 여부는 project 운영 정책을 따릅니다.
- FK를 사용하지 않으면 application validation, batch consistency check와 monitoring 등 대체 무결성 전략을 명시합니다.
- cascade delete는 data loss 위험을 검토하고 제한적으로 사용합니다.

### 12.6) DB 분리와 log table

- 업무 data와 대용량 log·event data의 DB 분리를 검토합니다.
- 서로 다른 DB의 transaction 보장 범위와 부분 성공 위험을 명시합니다.
- log table은 append 중심, 날짜·sequence 기반 PK와 조회 pattern에 맞는 index를 사용합니다.
- retention, partition과 archive 전략을 함께 검토합니다.

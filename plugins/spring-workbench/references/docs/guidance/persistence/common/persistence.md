# 공통 영속성 기준

모든 영속성 변경에 적용합니다. 프로젝트가 작업 대상 모듈에 지정한 기술 및 DB 지침도 함께 읽습니다. 적용 순서는 [영속성 인덱스](../README.md)를 따릅니다.

## 공통 영속성 원칙

- Service는 project가 정한 repository·DAO 계약에 의존하고 저장 기술의 세부 API를 직접 사용하지 않는다.
- persistence 구현은 query 실행, bind, mapping, generated key, update count와 기술 예외의 저장 계약 변환에 집중한다.
- 조회 결과 없음은 `Optional.empty()`나 빈 목록처럼 계약으로 표현할 수 있지만 update count 0의 domain 의미를 persistence 구현이 임의 예외로 바꾸지 않는다.
- 상태 전이, 중복 요청, 재시도와 경합의 업무 의미는 Service가 판단한다.
- query method는 반환 cardinality와 domain 의미가 이름에서 드러나야 한다.
- API·service test 편의를 위해 production repository·DAO에 전체 조회·삭제 method를 추가하지 않는다.

## 조회와 성능

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

## 상태 변경, transaction과 lock

- 여러 상태 변경이 함께 성공해야 하는 public use case는 service transaction이 원자성을 소유한다.
- 단순 조회 전달에는 근거 없이 read-only transaction을 붙이지 않는다.
- 외부 HTTP·broker와 긴 계산을 DB transaction 안에 두지 않는다.
- conditional update는 기대 상태·version·소유자 같은 경쟁 조건을 WHERE에 포함하고 update count를 반환한다.
- pessimistic lock은 읽은 값에 따라 다음 상태를 결정하며 동일 row 경쟁을 직렬화해야 할 때만 사용한다.
- optimistic lock은 충돌을 caller가 retry·실패로 처리할 명확한 정책이 있을 때 사용한다.
- 여러 row를 lock하면 획득 순서를 고정해 deadlock 위험을 줄인다.
- 여러 datasource·database를 묶는 transaction은 실제 원자성 보장 범위와 부분 성공 복구 정책을 기록한다.
- Spring으로 트랜잭션을 조립하는 경우 [Spring 트랜잭션 기준](../../development/implementations/spring/transactions.md)을 확인한다.

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

## 검증과 DB 제약

- 식별자와 자연 key 중복은 PK·UNIQUE로 보장한다.
- 필수 관계와 허용 범위는 실제 운영·migration 제약을 고려해 NOT NULL, CHECK, FK 또는 application 검증의 소유권을 명시한다.
- 저장 전에 전체 목록을 읽어 중복을 검사하지 않는다.
- application validation만으로 동시 요청 중복을 막을 수 있다고 가정하지 않는다.
- duplicate exception은 어떤 unique constraint가 발생했는지 구분할 필요가 있는 use case에서만 명시적으로 해석한다.
- 상태 문자열, enum mapping, boolean 표현과 time precision은 Java와 DB에서 일치해야 한다.
- decimal 금액·비율은 precision, scale과 rounding owner를 명시하고 floating-point type으로 바꾸지 않는다.

## Schema 변경의 소유권

- 대상 프로젝트의 schema source는 migration, `schema.sql`, ORM 검증 설정 또는 외부 schema 저장소 중 실제 배포에 권위를 갖는 위치입니다. 작업할 때 권위 있는 경로와 변경 절차를 확인하고, 비표준 소유 경계라면 프로젝트 전용 문서에 기록합니다.
- Java model만 보고 table 계약을 추정하지 않는다.
- column type·length·null·default, PK, secondary index, UNIQUE, FK와 comment를 확인한다. DB 엔진별 속성은 해당 기술 지침을 따른다.
- migration은 이전 배포 상태에서 순서대로 적용 가능한가를 검증한다.
- 이미 배포된 migration을 수정하지 않고 새 migration으로 변경한다. 단, 프로젝트가 최종 baseline만 관리하는 명시적 정책이면 그 정책을 따른다.
- baseline을 만들 때는 최초 DDL과 전체 변경 이력을 시간순으로 계산하고 현재 model만 보고 재구성하지 않는다.
- 운영 metadata·policy DML을 schema baseline에 섞지 않는다. bootstrap data의 별도 소유 경계를 확인한다.
- destructive change는 compatibility window, data migration, rollout 순서, rollback과 비용을 함께 계획한다.
- 실제 기준 DB와 Git schema가 다르면 어느 한쪽을 임의로 정답으로 고르지 않고 환경과 적용 기준을 확정한다.


### 최종 baseline DDL 산출

- 신규 환경용 baseline은 중간 `ALTER TABLE` 이력을 나열하지 않고 대상 버전에서 한 번에 생성 가능한 최종 `CREATE TABLE`을 둡니다. 단, 프로젝트가 순차 migration을 권위 있는 배포 방식으로 사용하면 이미 배포된 migration은 유지하고 신규 환경 검증에서 전체 migration 결과를 최종 schema와 대조합니다.
- 최종 DDL은 현재 Java model만 보고 재구성하지 않습니다. 최초 생성 SQL부터 대상 버전까지의 변경 이력, 삭제된 파일, 관련 branch와 실제 소비 애플리케이션의 추가 SQL을 시간순으로 확인합니다.
- column 이름·순서·type·length·NULL·default·PK·secondary index·UNIQUE·FK·comment와 DB 엔진별 속성의 최종값을 계산합니다. index는 model field만으로 드러나지 않으므로 별도 누락 검사를 수행합니다.
- 확인 가능한 기준 DB가 있으면 실제 테이블 정의와 인덱스 메타데이터를 대조합니다. Git과 실제 DB가 다르면 미기록 운영 변경으로 보고 적용 환경과 기준을 확정합니다.
- 빈 DB 또는 격리 schema에 적용한 뒤 실제 repository·DAO 저장·조회로 DDL, mapping과 실행 결과를 함께 검증합니다.

### metadata DML과 bootstrap data

- 운영·관리 화면이 소유하는 정책·catalog data를 schema baseline에 임의 `INSERT`하지 않습니다. 해당 data는 운영 업로드, seed migration 또는 별도 bootstrap 절차 중 실제 소유 경계를 따릅니다.
- 애플리케이션 기동 전에 반드시 필요한 bootstrap row와 운영자가 관리하는 정책 data를 구분합니다.
- 기존 DML을 제거할 때는 보이는 `INSERT`라는 이유만으로 삭제하지 않고 최초 계정, 권한, migration marker와 credential 공급 절차를 확인합니다.
- 테스트에 필요한 metadata는 공유 운영 seed에 기대지 않고 테스트 경계에서 실제 repository·DAO로 준비합니다.

## Schema와 DAO 검증

- 빈 database 또는 격리 schema에 전체 migration·schema source를 적용한다.
- 실제 table metadata와 index 목록을 확정 DDL과 대조한다.
- generated key, enum, decimal, time, JSON, nullable과 unique mapping을 실제 persistence test로 검증한다.
- conditional update의 success와 race-lost count를 함께 검증한다.
- transaction rollback과 마지막 저장 실패의 부분 성공 여부를 검증한다.
- production과 다른 embedded DB를 쓰면 dialect, lock, constraint와 time 차이를 별도 실제 DB test로 보완한다.
- 실행 명령은 [테스트 기준](../../verification/README.md)에 기록한 실제 DB·integration 명령을 사용한다. 별도 task가 없다면 repository·DAO 통합 테스트와 전체 migration 적용 절차를 각각 명시한다.

## Query·Schema 변경 완료 점검

- [ ] query cardinality와 반환 계약이 method 이름에 맞는가.
- [ ] 반복 조회, 불필요한 정렬과 over-fetch가 없는가.
- [ ] transaction owner와 lock 순서가 명확한가.
- [ ] update count 0과 duplicate의 업무 의미를 service가 판단하는가.
- [ ] migration·schema, Java mapping과 실제 DB가 일치하는가.
- [ ] index·unique·FK와 rollback·rollout 영향을 검증했는가.
- [ ] 실행하지 못한 실제 DB 검증과 이유를 남겼는가.

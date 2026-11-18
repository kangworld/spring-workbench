# JPA/Hibernate 사용 시 적용 기준

JPA/Hibernate 엔티티나 리포지토리를 변경할 때 [공통 영속성 기준](../common/persistence.md)과 함께 적용합니다.

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

## 패키지와 모델

- `entity`에는 JPA annotation, 영속성 식별자·연관관계와 persistence lifecycle을 가진 클래스만 둡니다. JPA와 무관한 계산 결과, 값 객체, 정책과 업무 상태를 `entity`에 두지 않습니다.
- JPA entity와 domain class를 패키지 형식을 맞추기 위해 일대일로 복제하지 않습니다. 영속성 관심사와 무관한 별도 업무 모델이 실제로 필요할 때만 변환 경계와 함께 분리합니다.
- JPA를 사용하면 저장 기술 구현을 `dao/jpa`에 둡니다. Spring Data interface를 별도 구현 없이 직접 저장 계약으로 사용하는 경우에는 `dao`에 두고 빈 `dao/jpa` 계층을 만들지 않습니다.

## 통합 테스트

[Spring 통합 테스트 기준](../../verification/implementations/spring/integration-testing.md)을 따르고, JPA 매핑과 제약만 확인할 때는 필요한 JPA 테스트 구성을 사용합니다.

```java
@DataJpaTest
@Transactional
class StoragePolicyRepositoryTest {

    @Test
    void testWhenInsertDuplicateTargetThenRejectByUniqueKey() {
        // 확정된 DB 중복 계약을 실제 DB에서 검증합니다.
    }
}
```

# 영속성 지침

영속성 변경에는 [공통 기준](common/persistence.md)을 먼저 적용합니다. 여기서는 저장소·DAO 계약, 서비스의 책임, 트랜잭션 경계와 스키마 검증을 정의합니다.

## 데이터 접근 구현

변경 대상 모듈이 사용하는 기술의 구현 기준을 읽습니다.

| 작업 대상 | 추가로 읽을 지침 |
| --- | --- |
| Spring Data JPA 또는 Hibernate 엔티티·리포지토리 | [JPA/Hibernate](implementations/jpa-hibernate.md) |
| Spring JDBC의 `JdbcTemplate`, `NamedParameterJdbcTemplate` 또는 DAO | [Spring JDBC](implementations/spring-jdbc.md) |
| MyBatis 매퍼, XML·어노테이션 SQL 또는 매핑 | [MyBatis](implementations/mybatis.md) |
| R2DBC 저장소 또는 리액티브 트랜잭션 | [R2DBC](implementations/r2dbc.md) |

## DB 엔진

[MySQL 기준](databases/mysql.md)은 접근 기술과 별개로 MySQL DDL, 인덱스 또는 전용 SQL을 변경할 때 함께 적용합니다.

## 적용 순서

1. 프로젝트 `AGENTS.md`에서 모듈이나 경로별 기술 스택과 DB 엔진을 확인합니다.
2. 작업 대상이 쓰는 실제 구현, 빌드 설정과 데이터소스 설정을 대조합니다. 선언이 비어 있으면 확인한 기술과 근거를 명시합니다. 선언이 실제 구현과 달라 변경 방향에 영향을 주면 차이를 사용자에게 알립니다.
3. 여러 기술을 쓰는 프로젝트에서는 각 변경 경로에 해당하는 문서를 따릅니다. DB 엔진별 지침은 해당 엔진의 DDL·인덱스·방언을 건드릴 때 추가합니다.
4. 새 프로젝트에서 데이터 접근 기술을 처음 선택할 때는 Spring Data JPA/Hibernate를 기본 후보로 고려합니다. 다른 기술을 선택하거나 기존 기술을 전환할 경우 쿼리 특성, 성능, 기존 계약과 운영 제약을 근거로 적용 이유와 범위를 남깁니다. 예제가 있거나 익숙하다는 이유만으로 JDBC를 선택하지 않습니다.

# DB 통합 테스트 자원과 fixture

[공통 테스트 기준](../../common/testing.md)과 [영속성 지침](../../../persistence/README.md)을 함께 적용합니다.

## 테스트 데이터와 공개 계약

- 테스트 코드에 `SELECT`, `INSERT`, `UPDATE`, `DELETE` 네이티브 SQL을 직접 작성하지 않습니다.
- 상태 생성과 조회는 실제 DAO, repository와 service의 공개 계약을 사용합니다.
- 테스트 데이터는 test transaction rollback으로 정리합니다.
- builder는 객체 생성만 담당하고 DB 저장은 테스트 본문에서 실제 DAO로 수행합니다.
- 쓰기 전용 로그 DAO의 service 테스트는 로그 테이블을 직접 조회하지 않습니다.
- 영속성 model과 mapping은 repository·DAO 테스트가 소유하고 service 테스트는 상태 변경과 transaction 결과를 검증합니다.
- 테스트 편의를 위해 운영 DAO에 조회·삭제 API를 추가하지 않습니다.
- DB mapping 모델의 기본 생성자와 mapping 경로를 보존합니다.

## DB 자원

- 여러 DB를 함께 쓰는 테스트는 각각의 pool과 transaction manager를 실제 구성합니다.
- 로컬 DB에 필요한 schema나 table이 없으면 테스트를 생략하지 않고 확정 DDL을 기준으로 먼저 구성합니다.
- 현재 범위의 DDL만 적용하고 실제 테이블 정의와 인덱스를 대조합니다. MySQL은 [스키마 확인 기준](../../../persistence/databases/mysql.md)을 따릅니다.
- 존재하지 않는 table을 과거 fixture나 Java 모델만 보고 임의 생성하지 않습니다.
- 소비 서버가 실제 사용하는 datasource와 계정으로 검증합니다.
- 범위 밖 table은 확정 스키마 근거가 있을 때만 구성하고 그렇지 않으면 관련 테스트를 분리해 결과를 기록합니다.
- connection 사용량 문제는 테스트 전용 pool 크기처럼 범위가 좁은 설정으로 해결합니다.
- 정리 순서와 고정 ID가 기존 테스트와 충돌하지 않는지 확인합니다.

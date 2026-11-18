# MySQL schema convention

MySQL DDL, 인덱스, 전용 SQL을 변경할 때 [공통 영속성 기준](../common/persistence.md)과 함께 적용합니다.

## 적용과 공통 규칙

- 대상 프로젝트의 확정 schema와 운영 compatibility를 우선합니다.
- 예외가 필요하면 이유, 영향 범위, compatibility와 rollback point를 기록합니다.
- table과 column은 `snake_case`, UTF-8은 `utf8mb4`를 기본으로 합니다.
- table comment와 주요 column comment를 작성합니다.
- 금칙어나 예약어는 피하고 약어는 project convention에 맞게 제한합니다.

## 실제 스키마 확인

- 기준 DB의 `SHOW CREATE TABLE` 결과와 인덱스 메타데이터를 DDL과 대조합니다.
- baseline의 storage engine, charset·collation과 signed·unsigned 속성을 함께 확인합니다.

## 이름과 식별자

- 새 table은 단수형 이름을 기본으로 하되 기존 운영 규칙과 충돌하면 기존 규칙을 따릅니다.
- PK는 `{table}_id` 또는 domain identifier pattern을 일관되게 사용합니다.
- boolean 성격 column은 `is_*` 또는 `has_*` 중 project convention 하나를 사용합니다.
- enum·state column은 의미가 드러나는 이름을 사용합니다.
- index는 `idx$...`, unique index는 `uidx$...` 등 project naming pattern을 따릅니다.

## type, default와 null

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

## 시간

- 생성 시각은 `crt_date`, 수정 시각은 `upd_date` 등 project convention을 따릅니다.
- `crt_date`는 insert 시 DB server 시간을 사용하고 application에서 임의 주입하지 않습니다.
- `upd_date` 자동 갱신 여부를 명시합니다.
- timezone과 precision 기준을 통일합니다.
- domain 시각과 audit timestamp를 구분합니다.

## key, index와 FK

- PK는 업무 식별과 query pattern을 기준으로 결정합니다.
- unique 조건은 중복 방지 규칙을 DB constraint로 보강합니다.
- composite index는 WHERE, JOIN과 ORDER BY 순서를 기준으로 설계합니다.
- selectivity가 낮은 단일 column index는 신중히 사용합니다.
- index 추가 시 write cost와 storage cost를 함께 검토합니다.
- FK 사용 여부는 project 운영 정책을 따릅니다.
- FK를 사용하지 않으면 application validation, batch consistency check와 monitoring 등 대체 무결성 전략을 명시합니다.
- cascade delete는 data loss 위험을 검토하고 제한적으로 사용합니다.

## DB 분리와 log table

- 업무 data와 대용량 log·event data의 DB 분리를 검토합니다.
- 서로 다른 DB의 transaction 보장 범위와 부분 성공 위험을 명시합니다.
- log table은 append 중심, 날짜·sequence 기반 PK와 조회 pattern에 맞는 index를 사용합니다.
- retention, partition과 archive 전략을 함께 검토합니다.

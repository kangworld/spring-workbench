# MyBatis 적용 시

MyBatis 매퍼와 SQL 매핑을 변경할 때 [공통 영속성 기준](../common/persistence.md)과 함께 적용합니다.

- mapper interface와 XML·annotation query의 소유 위치를 기존 관례에 맞춘다.
- resultMap은 column·property mapping과 nested collection 조회를 명시적으로 관리한다.
- `${}` 문자열 치환은 identifier처럼 bind할 수 없는 검증된 값에만 제한하고 일반 입력에는 `#{}`를 사용한다.
- dynamic condition이 빠져 full-table update/delete가 되지 않도록 guard와 test를 둔다.
- mapper session과 Spring transaction 연결을 실제 integration test로 확인한다.

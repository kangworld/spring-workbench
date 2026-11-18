# backend-agent-docs

Java·Spring 백엔드에서 재사용하는 개발 지침을 관리하고 Codex 플러그인으로 배포합니다.

```text
backend-agent-docs/
|-- AGENTS.md
|-- docs/
|   |-- roles/                     조사, 구현, 검증, 기술 검토의 책임과 인계
|   |-- guidance/
|   |   |-- development/
|   |   |   |-- common/             아키텍처, 도메인, API, 설정, 모듈 통합
|   |   |   `-- implementations/   Java, Lombok, Spring, Jackson
|   |   |-- persistence/
|   |   |   |-- common/             저장소·DAO, 트랜잭션과 스키마의 공통 계약
|   |   |   |-- implementations/   JPA/Hibernate, Spring JDBC, MyBatis, R2DBC
|   |   |   `-- databases/          MySQL DDL, 인덱스와 방언 규칙
|   |   |-- verification/
|   |   |   |-- common/             테스트 범위, 디버깅, 누락 점검
|   |   |   `-- implementations/   Spring 통합 테스트, JUnit, DB 자원
|   |   `-- workflow/
|   |       |-- common/             구현 절차와 피처 문서
|   |       |-- git/                커밋 규약
|   |       `-- review/             프로젝트가 사용하는 리뷰 상태 기준
|   |-- templates/                 SQL 템플릿
|   |-- agents/                    기존 역할 경로에서 새 문서로 연결
|   `-- standards/                 기존 개발 지침 경로에서 새 문서로 연결
|-- tools/
|   |-- codex-plugin/skills/       구현과 검증 스킬 원본
|   `-- update-codex-plugin.ps1    배포본 동기화, 버전 갱신과 설치 검증
|-- plugins/backend-agent-docs/   역할, 스킬, 개발 지침을 담은 설치 패키지
`-- .agents/plugins/marketplace.json
```

스킬은 요청을 보고 맡을 역할과 읽을 지침을 고릅니다. 역할은 담당 범위와 결과를 문서로 정의합니다. Codex 네이티브 커스텀 역할은 사용자나 프로젝트의 `.codex/agents/` 설정으로 등록하므로, 플러그인에서는 역할 문서를 배포합니다. 일반적인 구현은 현재 세션에서 진행하고, 역할 위임은 사용자 요청이나 대상 프로젝트의 작업 지침을 따릅니다.

## 설치와 갱신

이 저장소를 Codex 데스크톱에서 열고 **Plugins → Backend Guidance → Backend Agent Docs → 설치**를 선택합니다. 목록에 새 마켓플레이스가 보이지 않으면 앱을 다시 열어 목록을 새로고침합니다.

이 저장소의 Codex 채팅에서 **“백엔드 공통 지침 플러그인 설치해줘”**라고 요청해도 됩니다. 공통 지침 원본을 수정한 뒤에는 **“백엔드 공통 지침 갱신해줘”**라고 요청합니다. Codex가 배포본을 동기화하고 내용이 바뀐 경우에만 버전을 올린 뒤, 이 PC의 설치본을 갱신하고 검증합니다. 대상 프로젝트에서는 새 채팅에서 사용합니다.

## 대상 프로젝트 설정

프로젝트 루트 `AGENTS.md`에 스킬 이름과 해당 프로젝트의 기술 스택을 적습니다. 여러 기술을 함께 쓰면 모듈 또는 경로까지 기재합니다.

```markdown
## 기술 스택과 적용 지침

- 서버는 Java 21과 Spring Boot 3을 사용한다.
- 주문 모듈 `src/main/java/example/order/`은 Spring Data JPA/Hibernate를 사용한다.
- 정산 모듈 `src/main/java/example/settlement/`은 Spring JDBC/JdbcTemplate을 사용한다.
- 관계형 DB는 MySQL이다.

백엔드 구현에는 `backend-agent-docs:spring-backend-guidance`를 적용한다.
개발 테스트와 코드 검토에는 `backend-agent-docs:spring-backend-verification`을 적용한다.
DB를 변경할 때는 공통 영속성 기준과 대상 모듈의 기술 기준을 읽는다.
MySQL DDL·인덱스·전용 SQL을 변경할 때는 MySQL 기준을 추가로 읽는다.
```

프로젝트 전용 요구사항, 스키마, 예외와 메모는 대상 프로젝트에서 관리합니다. 배포 파일을 변경하려면 `docs/` 또는 `tools/codex-plugin/skills/`의 원본을 수정합니다.

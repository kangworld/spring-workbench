# Spring Workbench

Java·Spring 서버 개발을 위한 Codex 플러그인. 프로젝트의 기술 스택에 맞춰 구현, 테스트, 코드 검토에 공통 지침을 적용합니다.

## 빠른 시작

- Codex의 **Plugins → Backend Guidance → Spring Workbench → 설치**. 이 저장소의 채팅에서 **“백엔드 공통 지침 설치해줘”**로도 설치 가능.
- 프로젝트 루트 `AGENTS.md`에 기술 스택, 모듈별 적용 경로, 스킬 ID 기록.
- 프로젝트에서 새 채팅을 열고 **“구현해줘”**.

구현을 맡기면 필요한 테스트도 작성하고 실행합니다. 구현과 테스트를 각각 검증하고, 문제를 고친 뒤 관련 테스트와 두 검증을 다시 돌립니다. [구현 작업 흐름](docs/guidance/workflow/common/implementation-workflow.md)

## 스킬

- 기능 구현과 버그 수정 [`spring-workbench:spring-backend-guidance`](plugins/spring-workbench/skills/spring-backend-guidance/SKILL.md)
- 테스트 작성·실행과 코드 검토 [`spring-workbench:spring-backend-verification`](plugins/spring-workbench/skills/spring-backend-verification/SKILL.md)
- 계약과 개발 지침 준수 여부 검증 [`spring-workbench:spring-backend-implementation-audit`](plugins/spring-workbench/skills/spring-backend-implementation-audit/SKILL.md)
- 테스트가 회귀를 잡는지 검증 [`spring-workbench:spring-backend-test-audit`](plugins/spring-workbench/skills/spring-backend-test-audit/SKILL.md)

## 지침

- 패키지 구조, 서비스 책임, API 계약. Java·Spring·Lombok·Jackson 기준. [개발 지침](docs/guidance/development/README.md)
- 저장소 계약, 트랜잭션, 쿼리와 스키마. JPA/Hibernate·Spring JDBC·MyBatis·R2DBC·MySQL 기준. [영속성 지침](docs/guidance/persistence/README.md)
- 테스트 범위, 실패 경로, 디버깅. Spring 통합 테스트·JUnit·DB 픽스처 기준. [검증 지침](docs/guidance/verification/README.md)

## 갱신

- 공통 문서나 스킬을 수정한 뒤 이 저장소의 채팅에서 **“백엔드 공통 지침 갱신해줘”**. 저장소를 옮겼다면 새 위치에서 요청.
- 갱신 후 프로젝트에서 새 채팅 시작.

## 저장소 구조

<details>
<summary>파일 트리</summary>

```text
.
├── README.md                                     설치·사용 안내
├── AGENTS.md                                     저장소 작업 규칙과 문서 인덱스
├── .gitignore                                    로컬 작업 자료·산출물 제외
├── .agents/
│   └── plugins/
│       └── marketplace.json                      Codex 설치 목록과 패키지 경로
├── docs/
│   ├── roles/
│   │   ├── investigator.md                       계약·현재 동작·재현 근거 조사
│   │   ├── implementer.md                        승인 범위 내 구현·인계
│   │   ├── verifier.md                           테스트 실행과 미검증 범위 기록
│   │   └── reviewer.md                           변경을 계약에 대조해 문제·영향 검토
│   ├── guidance/
│   │   ├── development/
│   │   │   ├── README.md                         영역별 개발 지침 인덱스
│   │   │   ├── common/
│   │   │   │   ├── architecture.md               패키지, 계층, 의존 방향
│   │   │   │   ├── client-contracts.md           API 요청·응답과 소비자 호환성
│   │   │   │   ├── configuration.md              설정 소유권, 기본값, 운영값
│   │   │   │   ├── domain-implementation.md      서비스 책임, 상태 전이, 실행 경계
│   │   │   │   └── module-integration.md         모듈 재사용과 호환성 검증
│   │   │   └── implementations/
│   │   │       ├── java/
│   │   │       │   ├── coding-conventions.md     Java 이름, 모델, 스타일, 주석
│   │   │       │   └── module-linkage.md         JVM 의존성 바이너리 호환성
│   │   │       ├── lombok/
│   │   │       │   └── usage.md                  애너테이션 처리, 생성자, 빌더
│   │   │       ├── spring/
│   │   │       │   ├── configuration.md         프로필, 속성 바인딩, 빈 선택
│   │   │       │   └── transactions.md          트랜잭션 프록시, 전파, 원자성
│   │   │       └── jackson/
│   │   │           └── serialization.md         실제 설정으로 JSON 왕복 검증
│   │   ├── persistence/
│   │   │   ├── README.md                         접근 기술과 DB 엔진별 지침 인덱스
│   │   │   ├── common/
│   │   │   │   └── persistence.md                DAO 계약, 조회 성능, 잠금, 스키마 검증
│   │   │   ├── implementations/
│   │   │   │   ├── jpa-hibernate.md              엔티티 매핑, fetch, 영속성 컨텍스트
│   │   │   │   ├── spring-jdbc.md                SQL 바인딩, RowMapper, 갱신 건수
│   │   │   │   ├── mybatis.md                    매퍼, 결과 매핑, 동적 SQL
│   │   │   │   └── r2dbc.md                      리액티브 저장소와 트랜잭션 경계
│   │   │   └── databases/
│   │   │       └── mysql.md                      MySQL DDL, 인덱스, 방언 규칙
│   │   ├── verification/
│   │   │   ├── README.md                         작업·기술별 검증 지침 인덱스
│   │   │   ├── common/
│   │   │   │   ├── testing.md                    테스트 범위, 경계값, 실행 결과
│   │   │   │   ├── debugging.md                  재현, 원인 좁히기, 근거 기록
│   │   │   │   └── mismatch-prevention-checklist.md 계약·코드·테스트 누락 점검
│   │   │   └── implementations/
│   │   │       ├── spring/
│   │   │       │   └── integration-testing.md    실제 빈, 프로필, 프록시 검증
│   │   │       ├── junit/
│   │   │       │   └── test-style.md              테스트 이름, 구조, JavaDoc
│   │   │       └── database/
│   │   │           └── fixtures.md                테스트 데이터 준비와 자원 정리
│   │   └── workflow/
│   │       ├── README.md                         구현·Git·리뷰 절차 인덱스
│   │       ├── common/
│   │       │   ├── implementation-workflow.md    구현, 테스트, 수정과 재검증
│   │       │   └── feature-work-document.md      피처 문서의 범위, 단계, 검증 기록
│   │       ├── git/
│   │       │   └── commit-conventions.md          커밋 범위와 메시지
│   │       └── review/
│   │           └── review-and-quality-gates.md    리뷰 결과의 상태와 잔여 위험
│   ├── templates/
│   │   └── schema-template.sql                    SQL 스키마 작성 템플릿
│   ├── agents/                                    이전 역할 문서의 새 경로 안내
│   └── standards/                                 이전 지침의 새 경로 안내
├── tools/
│   ├── codex-plugin/skills/
│   │   ├── spring-backend-guidance/
│   │   │   └── SKILL.md                            구현·조사 스킬 원본
│   │   ├── spring-backend-verification/
│   │   │   └── SKILL.md                            테스트 설계·실행과 코드 검토 스킬 원본
│   │   ├── spring-backend-implementation-audit/
│   │   │   └── SKILL.md                            구현 준수 검증 스킬 원본
│   │   └── spring-backend-test-audit/
│   │       └── SKILL.md                            테스트 품질 검증 스킬 원본
│   └── update-codex-plugin.ps1                     배포본 동기화와 설치 검증
└── plugins/spring-workbench/
    ├── .codex-plugin/
    │   └── plugin.json                             플러그인 ID·표시 이름·버전
    ├── skills/                                     배포용 스킬 4개
    └── references/docs/                            배포용 역할·지침·템플릿
```

</details>

플러그인 ID `spring-workbench@backend-guidance`

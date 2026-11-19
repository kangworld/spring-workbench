# Spring Workbench

Java·Spring 서버를 개발할 때 쓰는 Codex 플러그인입니다. 구현, 버그 수정, 테스트와 코드 검토에 필요한 스킬과 공통 개발 지침을 담고 있습니다.

Codex는 대상 프로젝트의 `AGENTS.md`와 변경할 코드를 확인합니다. 공통 기준을 적용한 뒤, 작업에 필요한 기술별 지침을 골라 읽습니다.

[빠른 시작](#빠른-시작) · [사용 예시](#사용-예시) · [포함된 구성](#포함된-구성) · [저장소 구조](#저장소-구조) · [지침 갱신](#지침-갱신)

## 빠른 시작

1. 이 저장소를 Codex 데스크톱에서 열고 **Plugins → Backend Guidance → Spring Workbench → 설치**를 선택합니다. 이 저장소의 Codex 채팅에서 **“백엔드 공통 지침 플러그인 설치해줘”**라고 요청해도 됩니다.
2. 대상 프로젝트의 루트 `AGENTS.md`에 기술 스택과 사용할 스킬을 적습니다. 모듈마다 기술이 다르면 각 기술을 쓰는 경로도 함께 적습니다.
3. 대상 프로젝트에서 새 Codex 채팅을 열고 구현이나 테스트를 요청합니다.

대상 프로젝트에 맞게 아래 항목을 채웁니다.

```markdown
## 기술 스택과 적용 지침

- 언어와 프레임워크: <이름과 버전>
- 데이터 접근: <기술과 적용 모듈 또는 경로>
- 데이터베이스와 테스트: <사용하는 기술>

구현과 버그 수정에는 `backend-agent-docs:spring-backend-guidance`를 적용한다.
테스트와 코드 검토에는 `backend-agent-docs:spring-backend-verification`을 적용한다.
공통 기준과 작업에 해당하는 기술별 지침을 읽는다.
```

## 사용 예시

| Codex에 하는 요청 | 확인할 내용 |
| --- | --- |
| “이 기능을 추가하기 전에 프로젝트에서 따를 기준을 확인해줘.” | 프로젝트의 계약, 변경할 계층과 적용할 기술 지침 |
| “이 버그를 재현하고 회귀 테스트를 추가해줘.” | 실패 경로, 실제 테스트 구성, 수정 전후 결과 |
| “이 API 변경이 기존 클라이언트와 호환되는지 검토해줘.” | 공개 계약, 직렬화 설정과 기존 응답의 차이 |

## 포함된 구성

### 스킬과 역할

| 스킬 | 적용할 작업 |
| --- | --- |
| `spring-backend-guidance` | Java·Spring 기능 구현, 버그 조사와 수정 |
| `spring-backend-verification` | 회귀 테스트 설계·실행, 실패 원인 조사, 요청받은 코드 검토 |

조사 역할은 계약과 재현 근거를 모으고, 구현 역할은 합의된 범위에서 코드를 바꿉니다. 검증 역할은 테스트 결과와 미검증 범위를 기록합니다. 코드 검토를 요청하면 검토 역할이 변경과 계약을 대조합니다. 역할은 보통 현재 세션에서 수행하며, 위임 여부는 사용자 요청이나 프로젝트 지침을 따릅니다.

### 공통·기술별 지침

| 영역 | 공통 기준 | 기술별 기준 |
| --- | --- | --- |
| [개발](docs/guidance/development/README.md) | 아키텍처, 서비스 책임, API 계약, 설정, 모듈 통합 | Java, Lombok, Spring 설정·트랜잭션, Jackson |
| [영속성](docs/guidance/persistence/README.md) | 저장소 계약, 원자성, 조회 성능, 스키마 검증 | JPA/Hibernate, Spring JDBC, MyBatis, R2DBC, MySQL |
| [검증](docs/guidance/verification/README.md) | 테스트 범위, 실패 경로, 디버깅 | Spring 통합 테스트, JUnit, DB 테스트 자원 |

프로젝트별 요구사항, 스키마, 기술 스택과 예외는 각 서버 저장소에서 관리합니다. 여러 프로젝트에 반복 적용하는 기준은 Spring Workbench에 둡니다.

## 저장소 구조

```text
.
├── README.md                                     설치와 사용 안내
├── AGENTS.md                                     이 저장소의 작업 규칙과 문서 인덱스
├── .gitignore                                    로컬 작업 자료와 산출물 제외
├── .agents/
│   └── plugins/
│       └── marketplace.json                      Codex 설치 목록과 패키지 경로
├── docs/
│   ├── roles/
│   │   ├── investigator.md                       계약·현재 동작·실패 원인 조사
│   │   ├── implementer.md                        승인된 범위의 구현과 인계
│   │   ├── verifier.md                           테스트 실행과 미검증 범위 기록
│   │   └── reviewer.md                           요청받은 변경의 문제와 영향 검토
│   ├── guidance/
│   │   ├── development/
│   │   │   ├── README.md                         변경 영역별 개발 지침 인덱스
│   │   │   ├── common/
│   │   │   │   ├── architecture.md               패키지, 계층, 의존 방향
│   │   │   │   ├── client-contracts.md           API 요청·응답과 소비자 호환성
│   │   │   │   ├── configuration.md              설정 소유권, 기본값, 운영값
│   │   │   │   ├── domain-implementation.md      서비스 책임, 상태 전이, 실행 경계
│   │   │   │   └── module-integration.md         모듈 재사용과 호환성 검증
│   │   │   └── implementations/
│   │   │       ├── java/
│   │   │       │   ├── coding-conventions.md     Java 이름, 모델, 스타일, 주석
│   │   │       │   └── module-linkage.md         JVM 의존성의 바이너리 호환성
│   │   │       ├── lombok/
│   │   │       │   └── usage.md                  애너테이션 처리, 생성자, 빌더
│   │   │       ├── spring/
│   │   │       │   ├── configuration.md         프로필, 속성 바인딩, 빈 선택
│   │   │       │   └── transactions.md          트랜잭션 프록시, 전파, 원자성
│   │   │       └── jackson/
│   │   │           └── serialization.md         실제 설정을 사용한 JSON 왕복 검증
│   │   ├── persistence/
│   │   │   ├── README.md                         접근 기술·DB 엔진별 지침 인덱스
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
│   │   │   ├── README.md                         작업과 기술에 맞는 검증 지침 인덱스
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
│   │       │   ├── implementation-workflow.md    구현 범위, 진행, 완료 보고
│   │       │   └── feature-work-document.md      피처 문서의 범위, 단계, 검증 기록
│   │       ├── git/
│   │       │   └── commit-conventions.md          커밋 범위와 메시지
│   │       └── review/
│   │           └── review-and-quality-gates.md    리뷰 결과의 상태와 잔여 위험
│   ├── templates/
│   │   └── schema-template.sql                    SQL 스키마 작성 템플릿
│   ├── agents/                                    기존 역할 문서 주소에서 새 문서로 안내
│   └── standards/                                 기존 지침 주소에서 새 문서로 안내
├── tools/
│   ├── codex-plugin/skills/
│   │   ├── spring-backend-guidance/
│   │   │   └── SKILL.md                            구현·조사 스킬 원본
│   │   └── spring-backend-verification/
│   │       └── SKILL.md                            검증·검토 스킬 원본
│   └── update-codex-plugin.ps1                     배포본 동기화와 설치 검증
└── plugins/backend-agent-docs/
    ├── .codex-plugin/
    │   └── plugin.json                             플러그인 ID, 표시 이름, 버전
    ├── skills/                                     설치용 스킬 사본
    └── references/docs/                            설치용 역할·지침·템플릿 사본
```

## 지침 갱신

공통 문서나 스킬 원본을 수정한 뒤 이 저장소의 Codex 채팅에서 **“백엔드 공통 지침 갱신해줘”**라고 요청합니다. Codex가 배포본을 동기화하고 내용이 바뀌었으면 버전을 올립니다. 설치본까지 갱신한 뒤 대상 프로젝트의 새 채팅에서 사용할 수 있습니다.

저장소 폴더를 옮겼다면 새 위치를 연 Codex 채팅에서 같은 문장으로 갱신을 요청합니다. 로컬 마켓플레이스도 새 저장소 경로를 사용하게 됩니다.

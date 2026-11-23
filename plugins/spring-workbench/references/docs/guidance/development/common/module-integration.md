# 모듈 통합 기준

## 1) 소유권 판단

기능을 구현하기 전에 다음 순서로 판단합니다.

1. 현재 서버나 기존 모듈에 같은 계약이 있는가
2. 후보 모듈이 구현체, 공통 계약·SPI, 설정 또는 인프라 중 무엇을 소유하는가
3. 요구 기능이 현재 프로젝트 전용 데이터와 정책에 묶이는가
4. 다른 소비 프로젝트에서도 독립적으로 재사용할 수 있는가
5. 서버 내부 구현과 모듈 확장 각각의 호환성, 배포와 운영 비용은 무엇인가

소스 양, artifact 이름, 현재 직접 호출 여부와 build dependency 하나만 보고 역할이나 불필요 여부를 단정하지 않습니다. public API, auto-configuration, 설정, Git 이력과 실제 소비자를 함께 확인합니다.

## 2) 재사용과 변경 범위

- 공통 모듈이 이미 소유한 계약을 프로젝트 전용 interface나 wrapper로 중복 정의하지 않습니다.
- 한 소비자의 편의를 위해 공통 모듈에 프로젝트 전용 정책을 넣지 않습니다.
- 실제 사용처와 독립된 책임이 확인되지 않은 추상화는 서버 내부에 두고 성급히 공통화하지 않습니다.
- 피처 구현에 모듈 변경이 실제로 필요한 경우에만 승인 범위에 포함합니다.
- 전체 모듈의 버전 통일이나 최신화는 현재 기능 범위에 자동으로 포함하지 않습니다.

## 3) 호환성 조사

- dependency tree로 요청 버전, 선택 버전, scope, exclusion과 실제 유입 경로를 확인합니다. JVM 라이브러리는 [바이너리 호환성 기준](../implementations/java/module-linkage.md)을 함께 적용합니다.
- reflection 문자열, service discovery, annotation, auto-configuration, serialization과 의미 변화는 정적 linkage 검사만으로 확인할 수 없으므로 관련 runtime 테스트를 실행합니다.
- 설정 key와 bean 이름이 같더라도 생성 type과 소비 방식이 다를 수 있으므로 실제 등록 조건과 consumer를 확인합니다.

## 4) 프레임워크·라이브러리 전환

- 프레임워크 호환 오류를 서버의 임시 의존성으로 덮지 않습니다.
- model, annotation 해석기, 공통 모듈처럼 함께 동작하는 경계를 같은 호환 라인으로 검토합니다.
- 기존 API, 설정 key와 bean 이름은 가능한 한 유지합니다. 변경이 불가피하면 대체 방식, 소비자 영향과 전환 절차를 기록합니다.
- runtime·compile scope는 IDE 오류를 없애기 위해 임의 변경하지 않고 실제 사용 지점으로 결정합니다.
- exclusion은 원천 모듈과 소비 서버 중 어느 쪽이 책임져야 하는지 영향 범위와 승인 기준으로 결정합니다.

## 5) 모듈 저장소 작업

- 모듈 저장소를 변경하기 전에 branch, remote tracking과 dirty 상태를 확인합니다.
- dirty worktree를 자동 stash, reset, clean 또는 commit하지 않습니다.
- 기준 branch와 최신 version은 현재 checkout이나 소비 서버 build 파일만 보고 정하지 않고 원격 branch·tag·build metadata를 대조합니다.
- version branch가 필요하면 해당 저장소의 실제 versioning 규칙을 따릅니다. 특정 프로젝트의 branch 형식을 전역 규칙으로 강제하지 않습니다.
- 일반 기능 작업은 명시적 요청 없이 branch, commit, push, PR과 merge를 수행하지 않습니다.
- 사용자가 모듈 마이그레이션과 검증 완료 commit까지 명시적으로 승인한 경우에만 그 범위를 수행합니다.

## 6) 검증

- 모듈 자체 compile, test와 필요한 install 또는 publish-local 검증
- 소비 서버의 dependency tree와 최종 runtime classpath 확인
- binary linkage 검사
- 의존성 설정, 리플렉션, 직렬화, 데이터 접근과 대표 호출 경로의 런타임 테스트
- 기존 소비자 호환 테스트
- 적용·rollback 절차와 아직 검증하지 못한 범위 기록

빌드 선언만 바뀐 상태를 통합 완료로 판단하지 않습니다. 최종 소비 애플리케이션에서 선택된 artifact와 실제 동작을 확인합니다.

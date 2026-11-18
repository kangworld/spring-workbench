# Spring 통합 테스트

[공통 테스트 기준](../../common/testing.md)에 따라 프록시, 트랜잭션, 어드바이저와 매퍼를 실제 컨텍스트에서 검증할 때 적용합니다.

## 테스트 컨텍스트

- Spring component인 service와 DAO를 테스트에서 `new`로 수동 생성하지 않습니다.
- 실제 빈을 주입해 프록시, 트랜잭션, 어드바이저와 매퍼 설정을 함께 검증합니다.
- 범용 수동 조립 객체를 새로 만들기 전에 기존 Spring test context를 확장합니다.
- 전체 context가 필요하지 않으면 `@ContextConfiguration`과 필요한 import로 최소 context를 구성합니다.
- context cache 전역 변경처럼 다른 테스트 전체에 영향을 주는 우회를 피합니다.

## 설정과 모듈 연동

- override 테스트는 실제 모듈 설정을 사용하고 가짜 속성을 추가하지 않습니다.
- 재정의한 실제 값과 재정의하지 않은 module default를 함께 검증합니다.
- 설정 파일 이름과 위치, PropertySource·Config Data loading과 bean 생성 결과를 실제 context에서 확인합니다.
- 전체 context 실패를 우회하려고 test resources에 main 설정을 중복하지 않습니다.
- 실패 원인과 실제 설정 경로를 먼저 확인합니다.
- 테스트별 fixture 설정은 소유 테스트에서만 import하고 운영 component scan에 섞지 않습니다.
- 테스트 통과만을 위한 placeholder bean이나 전역 설정을 추가하지 않습니다.

## 공통 서비스 컨텍스트

- service 통합 테스트는 실제 controller, service, advisor와 운영 설정을 조립해 wiring 오류를 함께 검증합니다.
- lazy initialization으로 조립 오류를 숨기지 않습니다.
- 공통 test annotation과 bootstrap을 사용하고 domain마다 scan package나 정규식을 추가하지 않습니다.
- bootstrap은 운영 애플리케이션 자동 탐색과 충돌하지 않는 명시적 test 시작점으로 둡니다.
- test 전용 configuration은 운영 component scan에서 제외하고 소유 테스트가 명시적으로 import합니다.
- 운영 bean을 테스트마다 다시 import하지 않고 외부 시스템이나 의도적으로 대체하는 경계만 mock으로 선언합니다.

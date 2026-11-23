# Java 모듈 바이너리 호환성

[공통 모듈 통합 기준](../../common/module-integration.md)에 따라 Maven 또는 Gradle에서 실제로 선택된 JVM 의존성을 검증합니다.

- API 제거 또는 버전 충돌 위험이 있으면 compile된 JAR의 class·method·field 참조를 최종 runtime classpath와 대조합니다.
- `jdeps`의 class·package 수준 결과만으로 method 단위 binary compatibility를 보장했다고 판단하지 않습니다.

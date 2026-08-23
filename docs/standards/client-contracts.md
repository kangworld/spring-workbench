# 클라이언트 계약 구현 기준

## 1) API 책임 경계

- 인증, 세션, 외부 검증과 도메인 처리는 서로 다른 수명주기와 실패 의미를 가지므로 한 service에 섞지 않습니다.
- controller는 transport parsing, 인증 주체 전달과 response 변환에 집중하고 도메인 규칙·transaction을 소유하지 않습니다.
- 공통 인증 resolver, response envelope와 부가 데이터 확장 지점이 있으면 개별 controller에서 반복 구현하지 않습니다.
- 성공과 실패 응답은 확정된 API 계약을 각각 따릅니다. 편의를 위해 field 구조, null·빈 collection과 error 형식을 임의 통일하지 않습니다.
- 아직 구현되지 않은 후속 기능의 데이터를 가짜 값, 빈 임시 model과 하드코딩 응답으로 먼저 노출하지 않습니다.
- error/result code와 wire field는 이름 관례로 추정하지 않고 계약 문서와 실제 ObjectMapper 설정으로 검증합니다.

워스트:

```java
public OrderResponse get(HttpServletRequest request, long orderId) {
	User user = authenticationService.resolve(request.getHeader("Authorization"));

	return orderService.get(user.id(), orderId);
}
```

베스트:

```java
public OrderResponse get(@AuthenticatedUser User user, long orderId) {
	return orderService.get(user.id(), orderId);
}
```

## 2) 요청·응답 모델

- API request·response는 persistence entity와 분리합니다.
- 입력 DTO는 transport 형식 검증을, domain/service는 상태와 업무 규칙 검증을 소유합니다.
- response에는 계약에 공개된 field만 포함하고 내부 cursor, lock version, 계산 편의 field와 credential을 노출하지 않습니다.
- 시간대, 정밀도, 금액 scale, enum 표현과 collection 순서는 계약에 맞춰 고정합니다.
- 빈 collection과 null의 의미가 다르면 변환 경계와 테스트에서 구분합니다.

## 3) 직렬화 경계

- 서버 persistence·domain 객체를 그대로 직렬화하지 않고 클라이언트 계약 전용 record 또는 DTO로 변환합니다.
- 목록 내부 항목도 서버 model을 그대로 노출하지 않습니다. 명시적으로 공유하기로 한 외부 계약 model만 예외입니다.
- 삭제 marker, delta와 outbox payload는 식별과 소비에 필요한 field만 가진 전용 type으로 만듭니다.
- key 생성은 최종 직렬화 type과 동일한 식별 계약을 사용합니다.
- 실제 운영 ObjectMapper로 serialize·deserialize round-trip, field 이름, polymorphic type과 unknown field 정책을 검증합니다.

워스트:

```java
public Object toPayload(Object value) {
	return (OrderEntity) value;
}
```

베스트:

```java
public Object toPayload(Object value) {
	Order order = (Order) value;

	return new OrderPayload(order.getId(), order.getStatus(), order.getUpdatedAt());
}

private record OrderPayload(long id, OrderStatus status, Instant updatedAt) {
}
```

## 4) 서버·소비자 정합성

- 서버 코드만 보고 클라이언트의 캐시, outbox, revision과 재동기화 동작을 단정하지 않습니다.
- API 변경 전 소비자 DTO, 역직렬화 정책과 실제 사용 흐름을 확인합니다.
- 호환 변경과 breaking change를 구분하고 versioning, rollout, rollback과 구버전 소비자 영향을 기록합니다.
- retry 가능한 요청은 idempotency key, 중복 응답과 처리 결과 조회 경로를 함께 설계합니다.
- contract test 또는 실제 소비자 integration test로 wire 결과를 검증합니다.

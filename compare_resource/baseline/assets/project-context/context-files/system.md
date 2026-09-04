# 시스템

## Runtime 구조

| Runtime 또는 시스템 | 책임 | 배포 위치 | 신뢰 경계 | 소유자 | Consumer |
| --- | --- | --- | --- | --- | --- |
| {{RUNTIME_이름}} | {{책임}} | {{배포_위치}} | {{신뢰_경계}} | {{소유자}} | {{CONSUMER}} |

## Rendering·hosting 호환성

| Route 또는 route 묶음 | Rendering | 필요한 runtime | Cache·revalidation 소유자 | 배포 대상 지원 근거 | 실패·rollback |
| --- | --- | --- | --- | --- | --- |
| `{{ROUTE_패턴}}` | {{CSR_SSR_SSG_또는_ISR}} | {{BROWSER_STATIC_NODE_SERVER_또는_EDGE}} | {{CACHE_REVALIDATION_또는_명시적_무캐시_소유자}} | {{HOSTING_구성_문서_또는_검증}} | {{실패와_ROLLBACK}} |

- Static output 가능 범위: {{STATIC_OUTPUT_ROUTE와_제약}}
- Server·edge runtime 필요 범위: {{SERVER_EDGE_ROUTE와_소유자}}
- ISR의 Node.js runtime·재검증 storage 지원 근거 또는 해당 없음: {{ISR_RUNTIME_STORAGE_근거_또는_해당_없음}}
- Rendering 선택과 application 기반의 정본: [software.md](software.md)

## 외부 시스템과 데이터 흐름

| 외부 경계 | Client 소유자 | 입력 validation·mapping | Base URL 또는 runtime 소스 | Timeout·retry | Error 계약 | Consumer |
| --- | --- | --- | --- | --- | --- | --- |
| {{경계_이름}} | `{{CLIENT_소유자_경로}}` | `{{검증_MAPPING_소유자}}` | {{RUNTIME_구성_소유자}} | {{TIMEOUT_RETRY_규칙}} | {{ERROR_유형_또는_MAPPING}} | {{CONSUMER}} |

### 지도 provider와 공간 데이터

| 역할 | Provider·출처 | 계약·attribution | Credential·허용 domain 소유자 | 사용량·비용 제한 | 실패·대체 동작 | Consumer |
| --- | --- | --- | --- | --- | --- | --- |
| {{TILE_STYLE_DATA_SEARCH_GEOCODING_역할}} | {{지도_PROVIDER_또는_해당_없음}} | {{계약_ATTRIBUTION_소유자}} | {{CREDENTIAL_DOMAIN_소유자}} | {{QUOTA_RATE_COST_제약}} | {{지도_PROVIDER_실패와_대체}} | {{CONSUMER}} |

지도 engine 선택과 component 경계는 [software.md](software.md)가 소유합니다. MapLibre GL JS·OpenLayers의 engine 이름만으로 tile·style·공간 데이터·검색·geocoding 공급자를 추론하지 않습니다. NAVER Maps API는 결합된 지도 플랫폼·browser client 식별자 범위와 별도 API·submodule 범위를 구분합니다.

## 인증과 권한 경계

- 브라우저에 보이는 인증 상태 소유자: {{CLIENT_인증_상태_소유자}}
- 자격 증명 전송 및 저장 경계: {{자격_증명_경계}}
- 최종 권한 판정 소유자: {{SERVER_권한_소유자}}
- 권한 실패 및 복구 동작: {{권한_실패와_복구}}

## 환경과 배포

| 변수 또는 runtime 값 | 공개 또는 서버 전용 | Validation 소유자 | 주입 소스 | 누락·오류 동작 |
| --- | --- | --- | --- | --- |
| `{{변수_이름}}` | {{공개_범위}} | `{{검증_소유자}}` | {{주입_소유자}} | {{실패_동작}} |

- 환경 변수 예시 정본: `{{환경_예시_경로}}`
- 배포 구성 소유자: {{배포_경로_또는_미구성_소유자}}
- 지원 runtime 및 브라우저: {{지원_환경과_소유자}}

## 운영 성능 측정

| 주요 route·흐름 | Field 수집 소스 | Device·network·traffic segment | 집계·percentile·기간 | 목표·경보 조건 | 소유자 | 마지막 결과·환경 |
| --- | --- | --- | --- | --- | --- | --- |
| `{{ROUTE_또는_사용자_흐름}}` | {{운영_측정_소스}} | {{측정_SEGMENT}} | {{집계_PERCENTILE_기간}} | {{목표와_ALERT_조건}} | {{운영_성능_소유자}} | {{실제_결과_환경_또는_미구성}} |

Lab 성능 budget과 실행 명령은 [software.md](software.md), 사용자 체감 목표는 [ui-ux.md](ui-ux.md)가 소유합니다. Field 자료가 아직 없으면 lab 결과를 field 통과로 표현하지 않고 수집 도입 소유자와 다음 행동을 기록합니다.

## Lifecycle과 실패

- 요청 취소: {{취소_규칙}}
- Listener, timer, subscription 또는 observer 정리: {{리소스_정리_규칙}}
- 실패를 화면과 로그에 드러내는 방식: {{실패_표현_규칙}}

## Runtime 검증

| 범위 | 절차 또는 명령어 | 기대 결과 | 마지막 결과 | 환경 또는 차단 요인 |
| --- | --- | --- | --- | --- |
| 개발·미리보기 접근 | {{접근_확인_절차와_주소}} | {{접근_기대값}} | {{통과_실패_차단_또는_미실행}} | {{재현_환경_또는_이유}} |
| 외부 연동 | `{{연동_검증_명령어_또는_절차}}` | {{연동_기대값}} | {{통과_실패_차단_또는_미실행}} | {{재현_환경_또는_이유}} |
| 배포 | `{{배포_검증_명령어_또는_미구성}}` | {{배포_기대값}} | {{통과_실패_차단_또는_미실행}} | {{재현_환경_또는_이유}} |

실제 명령어와 로컬 gate는 [software.md](software.md)가, 데이터의 내부 schema와 영속성은 [data-model.md](data-model.md)가 소유합니다. 보호 자산, 위협·오용 시나리오, 비밀값 정책 및 보안 검증은 [security.md](security.md)가 소유합니다.

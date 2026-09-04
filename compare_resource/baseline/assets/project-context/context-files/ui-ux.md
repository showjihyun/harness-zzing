# UI·UX

## 화면과 사용자 흐름

| 화면 또는 surface | 사용자 목표 | 진입·이탈 경로 | 핵심 action | 제품 흐름 소유자 |
| --- | --- | --- | --- | --- |
| {{화면_이름}} | {{사용자_목표}} | {{진입과_이탈}} | {{핵심_ACTION}} | [prd.md](prd.md) |

## 화면 상태 계약

| 화면 | Loading·pending | Empty | Error | Success | Stale | 복구 검증 |
| --- | --- | --- | --- | --- | --- | --- |
| {{화면_이름}} | {{LOADING_UI}} | {{EMPTY_UI}} | {{ERROR_UI}} | {{SUCCESS_UI}} | {{STALE_UI}} | {{테스트_STORY_또는_절차}} |

## 상호작용과 접근성

- 의미에 맞는 control과 접근 가능한 이름: {{의미와_이름_규칙}}
- Keyboard와 focus 동작: {{KEYBOARD와_FOCUS_규칙}}
- 실패 후 복구: {{상호작용_복구_규칙}}
- 반응형 동작과 지원 viewport: {{반응형_규칙과_소유자}}

## 사용자 체감 성능 기대값

| 주요 route·흐름 | 사용자 체감 목표 | 적용 지표와 기준 출처 | 대상 device·network·사용자 범위 | 우선순위와 제품 소유자 |
| --- | --- | --- | --- | --- |
| `{{ROUTE_또는_사용자_흐름}}` | {{로딩_반응성_시각_안정성_목표}} | {{적용_성능_지표와_기준_출처}} | {{DEVICE_NETWORK_SEGMENT_범위}} | {{우선순위와_제품_소유자}} |

실제 lab·field 측정 명령어, budget과 gate는 [software.md](software.md), 운영 수집·경보는 [system.md](system.md)가 소유합니다.

## 지도 UI 계약

지도가 필요하지 않으면 이 절을 제거합니다.

| Map surface | 초기 viewport·fit 규칙 | Loading·empty·error | Pointer·touch·keyboard | 선택·popup·overlay | 위치정보·복구 | 검증 |
| --- | --- | --- | --- | --- | --- | --- |
| {{지도_SURFACE}} | {{초기_VIEWPORT_FIT}} | {{지도_LOADING_EMPTY_ERROR}} | {{지도_INPUT_접근성}} | {{지도_SELECTION_OVERLAY}} | {{위치정보_거부와_복구}} | {{지도_UI_검증}} |

- 지도와 동등한 정보 또는 작업의 접근 가능한 대안: {{지도_대체_UI와_소유자}}
- Provider attribution 표시 규칙: {{ATTRIBUTION_UI_규칙과_소유자}}

## 디자인 자산 소유권

| 항목 | 정본 소유자 | 사용 규칙 | 기대값 검증 |
| --- | --- | --- | --- |
| Design token | {{TOKEN_소유자}} | {{TOKEN_규칙}} | {{TOKEN_검증}} |
| 공용 컴포넌트 | {{컴포넌트_소유자}} | {{재사용_및_확장_규칙}} | {{컴포넌트_검증}} |
| 기능 스타일 | {{기능_스타일_소유자}} | {{스타일_범위_규칙}} | {{스타일_검증}} |

UI 기대값과 사용자 체감 성능 목표는 이 문서가 소유하고, 컴포넌트 경계와 실제 테스트·성능 측정 명령어·gate는 [software.md](software.md)가 소유합니다.

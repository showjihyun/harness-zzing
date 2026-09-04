# 소프트웨어

## Baseline과 프로젝트 선택

- 지정된 Baseline: {{BASELINE_참조}}
- 프로젝트 또는 workspace 범위: {{프로젝트_범위}}
- Runtime 및 브라우저 지원 소유자: {{RUNTIME_지원_소유자}}

지정된 Baseline에서 발견한 적용 가능한 모든 `FTS-*` 항목마다 행 하나를 작성합니다.

| FTS ID | Baseline 상태와 선택지 | 프로젝트 선택 | 주장 유형 | 선택 출처 | 구현 소유자 | 결과 또는 공백 |
| --- | --- | --- | --- | --- | --- | --- |
| {{FTS_ID}} | {{BASELINE_상태와_선택지}} | {{프로젝트_선택_또는_미사용}} | {{현재_상태_결정_또는_계획}} | {{사용자_CONTEXT_또는_기본값}} | {{MANIFEST_구성_소스_또는_CI_경로}} | {{준수_미사용_연기_또는_공백}} |

## Rendering과 application 기반

- 기본 rendering 전략: {{CSR_SSR_SSG_ISR_또는_HYBRID}}
- Application 기반: {{REACT_SPA_또는_NEXTJS}}
- Router 소유자: {{REACT_ROUTER_TANSTACK_ROUTER_또는_NEXT_APP_ROUTER}}
- Build·dev 소유자: {{VITE_또는_NEXTJS_BUILD}}
- Server data·client cache 경계: {{NEXT_FETCH_정책_TANSTACK_QUERY_범위_또는_해당_없음}}
- Hosting·runtime 호환성 근거: [system.md](system.md)의 {{RUNTIME_호환성_근거}}
- 선택 이유와 대안: [decision.md](decision.md)의 {{RENDERING_APPLICATION_결정_ID}}

`hybrid` 또는 기본 전략의 예외가 있으면 모든 route 또는 route 묶음을 다음 표에 기록합니다. 예외가 없어도 기본 전략을 대표하는 행 하나를 남깁니다.

| Route 또는 route 묶음 | Rendering | 선택 이유 | 데이터 시점 | Cache·revalidation | Runtime | 근거·검증 |
| --- | --- | --- | --- | --- | --- | --- |
| `{{ROUTE_패턴}}` | {{CSR_SSR_SSG_또는_ISR}} | {{선택_이유}} | {{BUILD_REQUEST_CLIENT_시점}} | {{CACHE_REVALIDATION_또는_명시적_무캐시_규칙}} | {{BROWSER_NODE_SERVER_EDGE_STATIC}} | {{구성_경로와_검증}} |

Next.js `fetch`는 자동 cache를 가정하지 않습니다. 각 server data 경계의 cache·revalidation 또는 명시적 무캐시 정책과 client cache가 필요한 범위를 구현 근거와 함께 기록합니다. ISR route는 Node.js runtime 및 배포 대상의 재검증 지원 근거를 가져야 합니다.

## 지도 구현

- 지도 기능 필요 여부: {{필요_또는_해당_없음}}
- `FTS-26` 선택: {{MAPLIBRE_GL_JS_OPENLAYERS_NAVER_MAPS_API_또는_해당_없음}}
- Engine package·version·구성 소유자: {{지도_ENGINE_MANIFEST와_구성_또는_해당_없음}}
- Map component와 browser·client boundary: {{지도_COMPONENT와_CLIENT_BOUNDARY_또는_해당_없음}}
- Instance·listener·observer·request cleanup 소유자: {{지도_LIFECYCLE_소유자_또는_해당_없음}}
- 외부 tile·data·검색·geocoding provider: [system.md](system.md)의 {{지도_PROVIDER_소유자_또는_해당_없음}}
- UI 상태·interaction·접근성 기대값: [ui-ux.md](ui-ux.md)의 {{지도_UI_소유자_또는_해당_없음}}
- Credential·허용 domain·외부 입력 보안: [security.md](security.md)의 {{지도_보안_소유자_또는_해당_없음}}

지도 engine이 browser 기능을 요구하면 Next.js server boundary에서 평가하지 않습니다. Page의 rendering 전략과 interactive map의 client boundary를 별개로 기록하며, 선택하지 않은 지도 engine을 함께 설치하지 않습니다.

## 도구 체인 정본 소유자

| 항목 | 소유자 |
| --- | --- |
| 패키지 manifest | `{{MANIFEST_경로}}` |
| 패키지 관리자와 lockfile | `{{LOCKFILE_경로}}` |
| Workspace 구성 | {{WORKSPACE_구성_또는_해당_없음}} |
| 빌드 및 compiler 구성 | {{빌드_구성_경로}} |
| 환경 변수 예시 | {{환경_예시_경로}} |
| CI | {{CI_경로_또는_미구성_소유자}} |

## 실행 가능한 명령어

| 목적 | 명령어 | 기대 결과 | 참고 또는 주소 |
| --- | --- | --- | --- |
| 설치 | `{{설치_명령어}}` | {{설치_기대값}} | {{설치_참고}} |
| 개발 | `{{개발_명령어}}` | {{개발_기대값}} | {{개발_서버_주소}} |
| 빌드 | `{{빌드_명령어}}` | {{빌드_기대값}} | {{빌드_참고}} |
| 타입 검사 | `{{타입_검사_명령어}}` | {{타입_검사_기대값}} | {{타입_검사_참고}} |
| Lint 또는 정적 검사 | `{{LINT_명령어}}` | {{LINT_기대값}} | {{LINT_참고}} |
| 단위·컴포넌트 테스트 | `{{테스트_명령어}}` | {{테스트_기대값}} | {{테스트_참고}} |
| 통합·E2E | `{{E2E_명령어_또는_미사용}}` | {{E2E_기대값}} | {{E2E_참고}} |
| 미리보기 | `{{미리보기_명령어}}` | {{미리보기_기대값}} | {{미리보기_주소}} |

## 디렉터리와 모듈 소유권

| 경로 | 책임 | 허용된 의존성 | 의존 금지 대상 | 공개 surface |
| --- | --- | --- | --- | --- |
| `{{디렉터리_경로}}` | {{책임}} | {{허용된_의존성}} | {{금지된_의존성}} | {{공개_EXPORT_또는_계약}} |

- 의존성 방향: {{프로젝트_의존성_방향}}
- 순환 탐지 또는 검증: `{{의존성_검사_명령어_또는_구성}}`
- 생성 산출물과 원본: {{생성_경로와_원본}}

## Route 계약

| Route 또는 route 묶음 | 소유자 | Parameter와 validation | Loading 및 error 동작 | Consumer | 검증 |
| --- | --- | --- | --- | --- | --- |
| `{{ROUTE_패턴}}` | `{{ROUTE_소유자_경로}}` | {{PARAMETER_계약}} | {{ROUTE_상태}} | {{CONSUMER}} | {{ROUTE_테스트_또는_명령어}} |

## 상태 소유권

| 상태 | 종류 | 정본 소유자 | 수명과 범위 | 갱신 진입점 | 영속성 또는 무효화 | Consumer |
| --- | --- | --- | --- | --- | --- | --- |
| {{상태_이름}} | {{서버_클라이언트_URL_폼_파생_또는_영속}} | `{{소유자_경로}}` | {{수명과_범위}} | {{갱신_API}} | {{영속성_또는_무효화}} | {{CONSUMER}} |

- 경쟁하는 비동기 결과 적용 규칙: {{경쟁_결과_적용_규칙}}
- 취소 및 정리 소유자: {{취소_정리_소유자}}
- Optimistic 또는 여러 단계 변경의 실패 조정: {{실패_시_실제_결과와_조정}}

## 코드 품질 기준과 예외

| 품질 기준 | 적용 범위 | 통과 조건 | 강제 지점 | 제외·우회 소유자와 만료 | 근거 |
| --- | --- | --- | --- | --- | --- |
| {{TYPE_LINT_TEST_BUILD_또는_프로젝트_품질_기준}} | {{적용_경로와_제외_범위}} | {{측정_가능한_통과_조건}} | {{LOCAL_HOOK_CI_또는_REVIEW_GATE}} | {{예외_소유자_만료_또는_없음}} | {{구성_테스트_CI_또는_실행_근거}} |

Baseline이 수치나 도구를 직접 정하지 않은 품질 기준은 프로젝트 요구와 위험에 맞게 이 표에서 확정합니다. 도구가 설치됐다는 사실만으로 품질 gate가 답변된 것은 아니며, 적용 범위와 통과 조건을 함께 기록합니다.

### 코드 설계 경계

| 컴포넌트 또는 모듈 | 책임 | 비즈니스 규칙 최종 구현 소유자 | 공개 surface·계약 | 허용된 의존성 | Consumer | 독립 검증 |
| --- | --- | --- | --- | --- | --- | --- |
| `{{COMPONENT_또는_MODULE_경로}}` | {{RENDERING_INTERACTION_ORCHESTRATION_DOMAIN_책임}} | `{{비즈니스_규칙_소유자_또는_해당_없음}}` | {{PUBLIC_API_PROPS_HOOK_EVENT_계약}} | {{허용된_의존성_방향}} | {{CONSUMER}} | {{단위_계약_또는_통합_검증}} |

UI 컴포넌트가 비즈니스 규칙의 경쟁 소유자가 되지 않게 합니다. SOLID와 deep module은 이름 자체를 준수시키지 않고, 책임 응집도, 결합도, 캡슐화, 공개 surface의 안정성과 변경 파급을 설명할 때 사용합니다.

## 성능 검증과 budget

| 주요 route·흐름 | 지표와 기대값 출처 | Lab·field | 측정 환경·표본·percentile | 목표·budget | Gate·모니터링 | 소유자 | 초과 예외·만료 | 마지막 근거 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `{{ROUTE_또는_사용자_흐름}}` | {{적용_성능_지표와_기준_출처}} | {{LAB_FIELD_또는_둘_다}} | {{DEVICE_NETWORK_TRAFFIC_SEGMENT_SAMPLE_PERCENTILE}} | {{목표와_회귀_BUDGET}} | {{CI_운영_모니터링_ALERT_또는_절차}} | {{성능_소유자}} | {{예외_소유자_만료_또는_없음}} | {{실행_대시보드_또는_미실행_근거}} |

Lab 결과와 field 결과를 서로 대신하지 않습니다. Field 자료가 없는 초기 셋업에서는 lab 결과와 운영 측정 도입 소유자·다음 행동을 구분해 기록합니다. 사용자 체감 목표는 [ui-ux.md](ui-ux.md), 운영 field 수집·경보는 [system.md](system.md)가 소유합니다.

## 검증과 gate

| 범위 | 기대값 출처 | 명령어 | 통과 조건 | Gate 소유자 |
| --- | --- | --- | --- | --- |
| 타입·lint | {{정적_검사_기대값_출처}} | `{{정적_검사_명령어}}` | {{정적_검사_통과_조건}} | {{정적_GATE_소유자}} |
| 단위·컴포넌트 | {{테스트_기대값_출처}} | `{{테스트_명령어}}` | {{테스트_통과_조건}} | {{테스트_GATE_소유자}} |
| 빌드 | {{빌드_기대값_출처}} | `{{빌드_명령어}}` | {{빌드_통과_조건}} | {{빌드_GATE_소유자}} |
| 통합·E2E | {{E2E_기대값_출처}} | `{{E2E_명령어_또는_미사용}}` | {{E2E_통과_조건}} | {{E2E_GATE_소유자}} |

- 변경 모듈을 위한 가장 작은 집중 검사: `{{집중_검사_명령어}}`
- 완료 전 필수 검사: `{{필수_완료_명령어}}`
- CI와 hook 차단 조건: {{CI_HOOK_GATE와_소유자}}

UI 동작의 기대값은 [ui-ux.md](ui-ux.md), 외부 시스템과 runtime 검증은 [system.md](system.md), 보안 기대값과 보안 gate는 [security.md](security.md)가 소유합니다. 통과 결과를 얻기 위해 테스트, 타입 또는 lint gate를 약화하지 않으며 제외·우회에는 소유자와 만료 조건을 둡니다.

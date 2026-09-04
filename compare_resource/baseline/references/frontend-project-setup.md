# 프론트엔드 프로젝트 셋업

사용자가 지정된 Baseline에 따라 아직 초기화되지 않은 대상에 프론트엔드 프로젝트를 생성·초기화·스캐폴딩·부트스트랩해 달라고 할 때만 이 워크플로를 사용합니다. 이미 프론트엔드 프로젝트가 셋업된 대상에는 이 워크플로로 추가 구성, 문서 보완 또는 재셋업을 하지 않습니다. 기본 조직 소스는 [BASELINE.md](BASELINE.md)이며, 사용자가 다른 소스를 명시적으로 지정한 경우에만 그 소스를 사용합니다.

## 결과물

초기화되지 않은 대상에 선택된 스택이 Baseline을 준수하고, Context가 Baseline을 복사하지 않은 채 프로젝트의 유효한 선택을 기록하며, 완료 주장이 실제 명령어와 결과로 뒷받침되는 실행 가능한 프론트엔드 프로젝트를 만듭니다. 이미 셋업된 대상에서는 아무것도 변경하지 않고 판정 근거를 보고하는 것이 결과입니다.

셋업은 Baseline에 언급된 모든 기술을 전부 구현하는 작업이 아닙니다. 적용되는 각 FTS 역할에서 확정된 단일 선택만 설치하고 구성합니다. 열거된 대안은 선택해도 된다는 허용이지, 모든 대안을 설치하라는 지시가 아닙니다.

## 1. 대상을 안전하게 확정하기

1. 요청된 프로젝트 이름과 정확한 대상 경로, 그리고 대상을 포함하는 저장소 또는 워크스페이스 루트를 확정합니다.
2. 대상과 적용되는 에이전트 지침을 읽기 전용으로 조사합니다. 기존 파일과 사용자 변경을 보존합니다.
3. 아래 셋업 여부 gate를 적용합니다. Gate가 통과되기 전에는 지정된 Baseline 파싱, FTS 선택 질문, Context 폴더 질문, 생성기 실행 또는 파일 쓰기를 시작하지 않습니다.
4. Gate를 통과한 뒤 지정된 Baseline을 완전히 읽고 모든 `FTS-*` 행을 파싱합니다.
5. `BASELINE.md`를 프로젝트 안에 복사하지 않습니다. 조직 정본을 하나로 유지하고 프로젝트 Context에서 그 정본을 참조합니다.
6. Baseline에 전달 또는 운영 기술이 열거되어 있다는 이유만으로 배포 리소스, 외부 계정, 자격 증명, 운영 데이터 또는 원격 저장소를 만들지 않습니다.
7. 문서 경로를 정하기 전에 `AGENTS.md`, `CLAUDE.md`를 포함한 기존 루트·경로 범위 에이전트 진입점과 Context 소유 문서를 조사합니다. 그 우선순위와 범위를 보존합니다.

## 1a. 셋업 여부 gate

판정은 사용자가 요청한 정확한 대상 경로를 기준으로 합니다. 사용자가 초기화되지 않은 새 하위 경로를 명시했다면 초기화된 상위 저장소나 워크스페이스가 있다는 사실만으로 차단하지 않습니다. 다만 이 워크플로는 상위 프로젝트의 manifest, workspace 구성 또는 에이전트 지침을 변경할 권한을 부여하지 않습니다.

다음 중 하나가 대상에 있으면 **강한 셋업 근거**입니다.

- 프로젝트 manifest가 frontend framework·runtime·build 도구의 직접 의존성 또는 실제 `dev`·`build` 실행 script를 선언함
- framework·build 구성과 실제 source entry, app·route 구조 또는 브라우저 진입점이 함께 존재함
- 프로젝트 Context 또는 에이전트 인덱스가 실행 명령어와 구현 소유자를 선언하고, 그 선언과 일치하는 manifest·구성·source 근거가 존재함

다음은 단독으로 셋업 완료를 증명하지 않는 **보조 근거**입니다.

- 일반적인 `package.json` 또는 workspace manifest만 존재함
- lockfile, `node_modules`, build 산출물 또는 cache만 존재함
- `src`, `public`, test, CI, `AGENTS.md`, `CLAUDE.md` 또는 Context 문서 중 하나만 존재함
- 비어 있지 않은 디렉터리이거나 저장소가 초기화되어 있음

강한 셋업 근거가 하나 이상 있거나, 서로 독립적인 보조 근거가 세 개 이상이고 그중 하나가 실제 source 또는 build·framework 구성이라면 `이미 셋업됨`으로 판정합니다. 같은 생성기의 중복 산출물은 하나의 근거로 셉니다. 근거가 모순되거나 임계값에 가깝고 판정이 불명확하면 `판정 보류`로 두고 쓰기 없이 대상이 신규 프로젝트용인지 질문합니다.

`이미 셋업됨`이면 즉시 다음과 같이 종료합니다.

1. FTS 선택과 Context 보관 폴더를 묻지 않습니다.
2. 생성기, 패키지 설치, build, formatter 또는 cache를 만들 수 있는 명령을 실행하지 않습니다.
3. source, manifest, 구성, script, lockfile, Context, `AGENTS.md`, `CLAUDE.md`를 생성·수정·병합하지 않습니다.
4. `이미 셋업됨` 판정과 근거 파일을 보고하고 변경 사항이 없음을 밝힙니다.
5. 사용자가 함께 감사를 요청했다면 셋업은 건너뛰고 감사 워크플로만 읽기 전용으로 실행합니다. 감사 요청이 없다면 여기서 멈춥니다.

사용자가 “누락된 셋업만 추가”, “다시 셋업”, “강제 셋업”을 요청해도 이 셋업 워크플로의 gate를 우회하지 않습니다. 기존 프로젝트의 변경은 별도의 명시적 구현·migration 작업이거나 읽기 전용 Baseline 감사로 다루며, 이 스킬의 셋업 모드로 수행하지 않습니다.

## 1b. Context 보관 폴더 확정

Gate를 통과했더라도 비어 있지 않은 대상에 기존 파일과 충돌할 생성 경로가 있으면 덮어쓰기 전에 멈추고 병합 의도를 질문합니다. Gate 통과는 기존 파일의 덮어쓰기나 교체를 허가하지 않습니다.

대상에 새 Context 소유 위치가 필요하면 쓰기 전에 Context 문서 보관 폴더를 확정합니다. 사용자가 요청에서 이미 경로를 지정하지 않았다면 `context`, `docs`, `sot`, `직접 입력` 중 하나를 반드시 선택받습니다. 기본값을 임의로 고르지 않습니다. `직접 입력`은 별도의 대상 프로젝트 상대 경로를 입력받고 프로젝트 밖으로 벗어나지 않는지 검증합니다.

## 2. 하나의 유효한 프로젝트 스택 확정하기

스캐폴딩 전에 다음 확정 작업표를 만듭니다.

```text
FTS ID | Baseline 상태·선택지 | 프로젝트 선택 | 선택 출처 | 셋업 작업 | 결과
```

지정된 Baseline에서 행을 동적으로 확정합니다. FTS 개수나 기술 목록을 셋업 구현에 하드코딩하지 않습니다.

- `기본`은 사용자가 다른 선택을 요청했거나 적용되는 workspace 정책이 충돌하지 않는 한 질문 없이 Baseline 기본값을 사용합니다.
- `기본·허용`은 사용자 또는 적용되는 workspace Context가 명시적으로 허용된 대안을 선택하지 않는 한 명시된 기본값을 사용합니다.
- `허용`에서 사용자 또는 기존 Context가 이미 유효한 선택 하나를 제공했다면 그 선택을 사용합니다.
- `허용`에 아키텍처, 의존성, 생성 파일, 명령어 또는 런타임 동작을 바꾸는 선택지가 여러 개라면 미확정 결정 하나씩 질문합니다. 개인 선호로 선택하거나 모든 선택지를 설치하지 않습니다.
- 프로젝트 단위 자유 선택 또는 선택적 미사용 같은 문구는 해당 행에만 적용되는 허용으로 취급합니다. 미사용이 명시적으로 허용되고 해당 기능이 요청되지 않았다면 도구를 추가하지 않고 `미사용`으로 기록합니다.
- Baseline 값이 `미결정`이거나, FTS 행이 잘못됐거나 중복됐거나, 필수 조합이 호환되지 않는다고 해서 임의로 정해도 되는 것은 아닙니다. 정확한 공백을 드러내고 진행에 필요한 결정만 질문합니다.

### 2a. Rendering을 application 기반보다 먼저 확정하기

`FTS-04`를 해소하기 전에 React SPA 또는 Next.js 중 무엇을 쓸지 묻거나 선택하지 않습니다. 사용자 요청, `prd.md`에 들어갈 제품 요구 또는 명시적 답변에서 다음 결정 근거를 확인합니다.

- 공개 검색 노출과 social preview 필요 여부
- 초기 HTML과 first content 응답 요구
- 로그인 사용자별 개인화 또는 요청별 rendering 필요 여부
- 데이터 갱신 빈도와 cache·revalidation 요구
- build 시 정적으로 생성 가능한 route 범위
- server·edge runtime, 운영 비용 및 배포 대상 제약

근거만으로 하나의 전략이 정해지지 않으면 `CSR`, `SSR`, `SSG`, `ISR`, `hybrid` 중 `FTS-04` 선택 하나를 질문합니다. `hybrid`이면 application 기반을 묻기 전에 route 또는 route 묶음별 rendering, cache·revalidation 및 runtime을 확정합니다.

그다음 `FTS-05`에서 `React SPA`와 `Next.js` 중 application 기반을 확정합니다. React와 Next.js를 서로 배타적인 기술로 표현하지 않습니다. Next.js는 React 기반 framework이고, `React SPA`는 Vite와 별도 client router를 사용하는 application 구성을 뜻합니다.

### 2b. 명시된 호환성 규칙 적용하기

문서화되지 않은 결합 선택은 추론하지 않지만, Baseline의 `Rendering·application 호환성 규칙`은 조직 규칙으로 반드시 적용합니다.

- CSR은 React SPA를 기본으로 하며, 구체적인 Next.js 기능 또는 향후 route-level rendering 요구가 선택된 경우 Next.js를 허용합니다.
- SSR·SSG·ISR·hybrid는 현재 Baseline에서 Next.js를 요구합니다.
- React SPA는 `FTS-06`에서 React Router·TanStack Router 중 하나를 확정하고 `FTS-07`에서 Vite를 사용합니다.
- Next.js는 App Router와 Next.js 내장 build·dev tool이 `FTS-06`, `FTS-07` 역할을 소유합니다. 이 경우 React Router, TanStack Router, Vite를 같은 역할에 추가하거나 별도 선택 질문으로 제시하지 않습니다.
- React SPA의 `FTS-14` 기본은 TanStack Query입니다. Next.js server data는 Next.js `fetch`를 사용하되 자동 cache를 가정하지 않고 route·data 요구에 맞는 cache·revalidation 또는 명시적 무캐시 정책을 확정합니다. 실제 client cache 경계가 있을 때만 TanStack Query를 추가합니다.
- Next.js server boundary의 `FTS-15` 기본은 `fetch`입니다. Axios·Ky는 실제 browser·client 계약이나 별도 기능 요구가 있을 때만 선택합니다.
- `FTS-23`은 선택된 rendering의 server·edge runtime, static output, cache, revalidation 조건을 충족해야 합니다.

각 행의 선택은 호환성 규칙으로 범위가 하나로 좁혀져도 확정표에 별도로 기록합니다. 호환성 규칙을 적용하는 것은 모든 역할을 하나로 합치거나 구현 근거를 생략해도 된다는 뜻이 아닙니다.

### 2c. 지도 필요 여부와 엔진 확정하기

`FTS-26`은 프로젝트 요청에 지도 언급이 없다는 이유만으로 자동으로 `해당 없음` 처리하지 않습니다. 사용자 또는 적용되는 Context에 유효한 답이 없으면 다른 질문과 합치지 않고 다음 순서로 확인합니다.

1. `이 프로젝트에 지도 기능이 필요한가요?`
2. 필요하지 않으면 이유와 함께 `FTS-26`을 `해당 없음`으로 확정하고 지도 관련 package·script·credential·예제 코드를 추가하지 않습니다.
3. 필요하면 `지도 엔진을 선택해주세요: MapLibre GL JS, OpenLayers, NAVER Maps API`라고 질문하고 하나만 확정합니다.

이미 사용자가 필요 여부와 허용 엔진 하나를 명시했으면 다시 묻지 않습니다. 지도 엔진은 지도 화면을 rendering하는 기술 선택입니다. MapLibre GL JS·OpenLayers의 tile·style·공간 데이터·검색·geocoding 공급자는 요구되는 경우 별도 외부 시스템으로 확정합니다. NAVER Maps API는 NAVER 지도 플랫폼과 browser client 식별자 계약이 결합되지만, 별도 공간 데이터·검색·geocoding API와 선택적 submodule은 실제 요구가 있을 때만 확정합니다.

## 3. 확정된 행으로 셋업 계획 세우기

확정된 모든 행을 다음 중 하나로 분류합니다.

- **생성:** 선택에 필요한 파일을 스캐폴딩하거나 만듭니다.
- **구성:** 기존 스캐폴드에 구성, 스크립트 또는 통합을 추가합니다.
- **문서화:** 아직 로컬 산출물이 없는 플랫폼 또는 운영 선택을 기록합니다.
- **미사용:** Baseline이 미사용을 명시적으로 허용하고 프로젝트가 이를 선택했습니다.
- **연기:** 선택이 현재 상태가 아니라 계획입니다. 설치하거나 구현된 것으로 보고하지 않습니다.

변경 전에 선택들이 일관되고 실행 가능한 프로젝트를 이루는지 확인합니다. 특히 초기 파일에 실질적인 영향을 주는 rendering, application 기반, router, build 도구, package manager, styling, design system·component 방식, 상태·데이터 도구, 지도 필요 여부·엔진 및 검증 도구를 확정합니다. `FTS-04`, `FTS-05`, `FTS-06`, `FTS-07`, `FTS-14`, `FTS-15`, `FTS-23`, `FTS-26`을 Baseline 호환성 규칙에 함께 대입해 충돌이 없어야 합니다. 전달·운영 선택은 해당 Baseline 행이 허용할 때만 문서화 상태 또는 미사용 상태로 남길 수 있습니다.

다음 중 하나라도 발생하면 mutation 전에 중지합니다.

- SSR·SSG·ISR·hybrid에 React SPA를 선택함
- Next.js와 별도 React Router·TanStack Router 또는 Vite를 같은 application 역할에 선택함
- SSR·ISR 또는 이를 포함한 hybrid에 static-only hosting을 선택함
- ISR 또는 이를 포함한 hybrid에 Node.js runtime과 배포 대상의 재검증 지원이 없음
- hybrid인데 route별 rendering·cache·revalidation·runtime 소유자가 없음
- Next.js server data와 client cache의 경계를 밝히지 않은 채 Next.js cache와 TanStack Query를 같은 사실의 중복 소유자로 둠
- 지도 필요 여부가 미확정이거나, 지도가 필요한데 `FTS-26` 엔진이 미확정임
- Migration 또는 분리된 surface 결정 없이 MapLibre GL JS, OpenLayers, NAVER Maps API 중 둘 이상을 선택함
- Next.js server boundary에서 browser 전용 지도 SDK나 `window`, `document`, WebGL에 접근하도록 계획함

## 4. 프로젝트 생성 및 구성하기

- 선택한 기술의 유지보수되는 스캐폴더 또는 생성기가 필요한 구조를 안정적으로 만든다면 이를 우선 사용합니다. 추가 구성을 얹기 전에 생성 결과를 조사합니다.
- React SPA 조합은 React·TypeScript를 지원하는 Vite 생성 결과를 사용하고 확정된 client router를 구성합니다. Next.js 조합은 TypeScript와 App Router를 지원하는 유지보수되는 Next.js 생성 결과를 사용합니다. 생성기 옵션은 실행 시점의 권위 있는 도움말 또는 문서에서 확인합니다.
- Next.js 프로젝트에 React Router, TanStack Router 또는 Vite를 추가하지 않습니다. React SPA 프로젝트에 SSR·ISR을 흉내 내는 임의 server layer를 추가하지 않습니다.
- `FTS-26`이 `해당 없음`이면 지도 관련 산출물을 만들지 않습니다. 지도가 필요하면 선택한 엔진 하나만 설치·구성하고, 지도 instance·listener·observer·request의 생성과 cleanup 소유자를 명확히 둡니다.
- Next.js에서는 interactive map을 client boundary에 두되 page 전체 rendering 전략을 불필요하게 CSR로 바꾸지 않습니다. 지도 엔진이 browser global을 import 시점에 요구하면 server evaluation을 피하는 경계를 구성하고 production build로 검증합니다.
- MapLibre GL JS·OpenLayers의 tile·style·공간 데이터·검색·geocoding 공급자, credential, 허용 domain 또는 attribution을 지도 엔진 선택에서 추론하지 않습니다. NAVER Maps API는 기본 플랫폼 로드에 필요한 browser client 식별자와 등록 조건만 권위 있는 문서에서 확인하고, 별도 API나 submodule은 실제 요구가 있을 때만 구성합니다.
- 실행 시점에 선택된 생성기, 패키지 관리자, 기존 워크스페이스 제약 또는 권위 있는 패키지 메타데이터에서 패키지 버전을 결정합니다. 기억에 의존한 “최신” 버전을 하드코딩하지 않습니다.
- Baseline의 패키지 관리자와 정본 lockfile을 사용합니다. 다른 패키지 관리자의 lockfile을 남기지 않습니다.
- 모노레포에서는 기존 워크스페이스 소유자를 보존하고, 이 프로젝트에서 해당 FTS 선택이 확정된 경우에만 Turborepo, Nx 또는 다른 오케스트레이션 계층을 추가합니다.
- 생성된 프로젝트가 실제로 import·구성·실행하는 직접 의존성만 설치합니다. 미래에 사용할 수도 있다는 이유로 추가한 의존성은 현재 셋업이 아니라 계획입니다.
- 선택된 도구에 맞는 실행 가능한 설치, 개발, 빌드, 타입 검사, lint, 테스트 및 미리보기 명령어를 제공합니다. 조용히 성공하는 자리표시자 스크립트나 설치되지 않은 도구를 참조하는 스크립트를 추가하지 않습니다.
- 브라우저 공개 환경 규칙을 적용합니다. 비밀값이나 최종 권한 판정을 클라이언트 코드에 두지 않고, 외부 값을 경계에서 검증하며, 실제 자격 증명 없는 공개 환경 변수 예시를 사용합니다.
- 생성 산출물이 아니라 생성기 원본과 구성을 수정합니다. 스캐폴드가 공개 route, props, API, event, storage 계약을 도입하면 이를 명시적으로 유지합니다.
- 생성된 스타터에 실제 데이터 접근이나 상호작용이 있다면 loading, empty, error, success, stale, focus, keyboard 및 recovery 동작을 보존합니다. 스타터를 완성된 것처럼 보이게 하려고 가짜 성공 경로를 추가하지 않습니다.

선택된 디자인 시스템 또는 내부 컴포넌트 라이브러리에 제공되지 않은 문서, 자격 증명, 레지스트리 또는 패키지 좌표가 필요하면 추측하지 않습니다. 이용 가능한 권위 있는 소스를 사용하거나 통합이 차단되었다고 보고하고, 그 통합에 의존하지 않는 셋업 작업만 계속합니다.

## 5. 프로젝트 Context 만들기

이 단계 전에 [project-context-scaffold.md](project-context-scaffold.md)를 완전히 읽습니다. 이 문서는 기본 문서 구성, 재사용 템플릿, 라우팅 요구사항 및 기존 저장소의 초기화되지 않은 대상에 통합하는 동작을 정의합니다.

기존 Context 경로가 있으면 찾아서 따릅니다. 새 Context 소유자가 필요하면 1단계에서 확정한 보관 폴더에 해당 참조의 `prd.md`, `domain.md`, `data-model.md`, `ui-ux.md`, `software.md`, `system.md`, `security.md`, `decision.md` 템플릿을 프로젝트별 사실로 렌더링합니다. Context용 `README.md`는 생성하지 않습니다. 또한 일반적으로 대상 프로젝트 루트인 활성 지침 루트에 다음 두 진입점을 만듭니다.

- Context 인덱스와 공통 프로젝트 지침을 소유하는 `AGENTS.md`
- `@AGENTS.md`로 해당 정본을 불러오는 Claude Code용 `CLAUDE.md`

`AGENTS.md`는 8개 Context 문서의 실제 경로, 정본 소유 범위 및 읽기 조건을 직접 표시하는 `Context 인덱스`를 포함하고, 일치하는 경로가 누적된다고 명시해야 합니다. `CLAUDE.md`는 이 내용을 복제하지 않고 `@AGENTS.md` import로 라우팅합니다. `AGENTS.md`의 `{{CONTEXT_폴더}}` 표시를 실제 상대 경로로 치환합니다. 프로젝트 사실, 명령어, 스택 선택 및 결정은 에이전트 파일에 복제하지 않고 인덱스가 가리키는 Context 문서가 소유합니다.

Gate를 통과한 초기화되지 않은 대상이 기존 저장소 안에 있으면 유효한 지침 우선순위를 보존하고 대상 범위의 `AGENTS.md`에 `Context 인덱스`를 병합한 뒤 `CLAUDE.md`가 `@AGENTS.md`로 이를 불러오게 합니다. 관련 없는 기존 지침을 덮어쓰거나 경쟁하는 두 번째 Context 소유자를 만들지 않습니다. 기존 `CLAUDE.md`에 Claude 전용 지침이 있으면 보존하되 Context 인덱스는 복제하지 않습니다. 모노레포에서는 경로를 전역화하기 위해 허용된 대상 밖의 상위 지침 파일을 수정하지 않습니다. 저장소 정책이 어느 한 파일 또는 import를 의도적으로 금지한다면 정책을 우회하지 말고 그 예외와 소유자를 사용 가능한 에이전트 지침과 `decision.md`에 기록합니다.

최소한 다음을 기록합니다.

- 지정된 Baseline 참조와 프로젝트 범위
- 적용되는 각 행마다 현재 선택 하나 또는 명시적 미사용을 담은 확정 FTS 표
- `FTS-04`의 기본 및 route별 rendering과 그 근거, `FTS-05` application 기반, `FTS-06`·`FTS-07` 소유자
- 각 route의 데이터 시점, cache·revalidation 또는 명시적 무캐시 정책과 `FTS-23` 배포 대상의 지원 근거
- `FTS-26` 지도 필요 여부, 선택한 단일 엔진 또는 `해당 없음`, browser·rendering 경계와 외부 지도 provider 소유자
- 각 선택이 현재 상태, 결정 또는 연기된 계획 중 무엇인지
- 정본 manifest, lockfile, 구성, 소스, CI 및 배포 소유자
- 실제로 존재하는 설치, 개발, 빌드, 타입 검사, lint, 테스트 및 미리보기 명령어
- 코드 품질 gate의 통과 조건·적용 범위·강제 지점과 제외·우회 예외의 소유자·만료
- 컴포넌트·모듈 책임, 비즈니스 규칙 최종 구현 소유자, 공개 surface·계약, 의존성 방향과 독립 검증 경로
- 주요 route·사용자 흐름의 성능 지표·기준 출처·lab 측정 조건·budget과, field 자료가 없을 때 운영 수집 소유자·다음 행동
- 적용되는 보안 통제·취약점 처리 기준·예외 만료와 신뢰하지 않는 콘텐츠 출력 경로의 XSS 방어·검증 또는 근거가 있는 `해당 없음`
- Baseline 편차 또는 미확정 공백과, 존재하는 경우 연결된 결정 소유자
- 검증 명령어와 셋업 중 실제로 관찰한 결과

조직 수준 Baseline 설명을 Context에 복사한 뒤 프로젝트 근거라고 부르지 않습니다. Context는 프로젝트에서 확정한 선택을 설명하고 이를 증명하는 파일 또는 명령어를 가리켜야 합니다.

이 단계를 마치기 전에 선택된 보관 폴더가 대상 프로젝트 내부에 있는지, `CLAUDE.md`가 `@AGENTS.md`를 불러오는지, `AGENTS.md`의 `Context 인덱스`에 표시된 모든 경로 대상이 존재하는지, Context용 `README.md`가 생성되지 않았는지, 모든 템플릿 표시가 교체되었는지, Baseline의 8개 Context 주제와 공통 코드 설계·성능·보안 기준이 8개 소유권 문서에 빠짐없이 연결되는지 확인합니다. 알 수 없는 사실은 소유자와 다음 행동을 포함해 `미확인` 또는 `미결정`으로 작성해야 하며, 템플릿 채움 문구로 남기거나 만들어내면 안 됩니다.

## 6. 위험에 비례해 검증하기

셋업 후 생성된 프로젝트를 적용되는 모든 확정 FTS 행과 대조하고, 추가되거나 충돌하거나 사용되지 않는 스택 선택이 있는지 조사합니다.

해당 도구가 존재하면 최소한 다음을 수행합니다.

1. 선택한 패키지 관리자와 단일 정본 lockfile을 확인합니다.
2. 의존성을 성공적으로 설치합니다.
3. 타입 검사와 정적 검사를 실행합니다.
4. 단위·컴포넌트 테스트를 실행합니다.
5. 운영 빌드를 실행합니다.
6. 필요한 런타임을 이용할 수 있으면 초기 셋업에 선택된 통합·E2E·시각·접근성 검사를 실행합니다.
7. 개발 또는 미리보기 서버를 충분히 실행해 앱에 접근할 수 있고, 시작이 깨졌을 때 실패가 명확히 드러나는지 확인합니다.
8. `CLAUDE.md`가 `@AGENTS.md`로 라우팅되는지, `AGENTS.md`의 Context 인덱스에서 8개 경로 대상이 모두 존재하는지, 공통 코드 설계·성능·보안 기준의 소유자가 연결되는지, 미해결 템플릿 표시가 없는지 검증합니다.
9. 생성된 route와 구성에서 선택한 rendering이 실제로 성립하는지 확인하고, cache·revalidation 정책과 배포 runtime 지원 근거를 `software.md` 및 `system.md`와 대조합니다.
10. 지도가 필요하면 선택한 engine 하나만 설치·import되는지, Next.js client boundary, 지도 lifecycle cleanup, loading·error·empty UI, provider credential·domain 및 attribution 요구가 구현과 Context에 일치하는지 확인합니다.
11. 신뢰하지 않는 콘텐츠를 출력하는 surface가 있으면 raw HTML·DOM·HTML/Markdown renderer와 sanitization 경계를 조사하고, 적용되는 XSS 검증을 실행합니다. 해당 surface가 없으면 조사 근거와 함께 `해당 없음`으로 기록합니다.
12. 이용 가능한 도구로 주요 route의 선언된 lab 성능 측정을 실행하고 조건·결과를 기록합니다. Field 자료가 없으면 lab 통과로 대체하지 않고 운영 수집 소유자와 다음 행동을 확인합니다.

통과 결과를 얻으려고 타입, lint 또는 테스트 gate를 약화하지 않습니다. 브라우저 바이너리, 자격 증명, 내부 레지스트리, 서비스 또는 배포 환경을 이용할 수 없다면 성공했다고 주장하지 말고 이유와 함께 `실행 차단` 또는 `미실행`으로 기록합니다. 셋업 후 FTS 준수 검사는 필수이며, 8개 주제와 공통 코드 설계·성능·보안 기준 및 21개 규칙 전체에 대한 Context 감사는 사용자가 결합 작업을 요청한 경우에만 필요합니다.

## 7. 결과 보고하기

Gate가 차단했다면 `이미 셋업됨`, 판정 근거 및 변경 사항 없음부터 밝히고 여기서 종료합니다. Gate를 통과해 셋업했다면 프로젝트가 실행 가능한지와 어디에 생성되었는지를 먼저 밝힙니다. 그다음 다음 항목을 보고합니다.

- 확정된 FTS 선택과 미사용 또는 연기 항목
- 기본 및 route별 rendering, application 기반과 배포 runtime의 호환성 결과
- 지도 필요 여부와 선택한 engine, 지도 rendering·provider 호환성 결과
- 생성되거나 변경된 중요 파일
- 선택된 Context 보관 폴더
- 실제 명령어와 결과
- 차단된 검증 또는 통합
- Baseline 편차 또는 미확정 결정
- 필요한 경우 가장 작은 다음 행동

필수 선택이 미확정 상태이거나, 필요한 생성 파일이 없거나, 선택한 프로젝트의 핵심 설치·빌드·검증 경로가 실패하는 동안에는 셋업이 완료됐다고 하지 않습니다.

# 2. 프론트엔드 기술 스택 기준

하나의 조직 Baseline을 사용한다는 것은 모든 프로젝트를 무조건 같은 도구로 구현한다는 뜻이 아닙니다. 조직은 영역별 기본값과 허용 범위를 하나의 정본에서 관리하고, 프로젝트는 그 범위 안에서 실제 적용한 조합을 명시합니다. 조직 기본값이 없는 영역은 기존 코드나 개인 선호를 사실상의 표준으로 간주하지 않고 `미결정`으로 기록합니다.

## 조직 표준 기술 스택

다음 표는 이 팀·회사가 실제로 사용하는 프론트엔드 기술 스택의 정본입니다. 각 항목은 한 번에 하나씩 결정하며, 결정 전에는 `미결정`, 적용하지 않기로 확인한 항목은 이유와 함께 `해당 없음`으로 둡니다. 연관된 기술을 함께 쓰는 경우에도 각 행의 역할과 선택을 따로 확정합니다.

| ID | 분류 | 결정 항목 | 조직 기본값 | 상태 |
| --- | --- | --- | --- | --- |
| **FTS-01** | 언어 | 기본 개발 언어 | TypeScript | 기본 |
| **FTS-02** | 실행 환경 | frontend toolchain runtime | Node.js | 기본 |
| **FTS-03** | 실행 환경 | 지원 browser | Chrome, Edge, Safari, Firefox 및 모바일 브라우저 | 기본 |
| **FTS-04** | Application | rendering 전략 | CSR, SSR, SSG, ISR, hybrid 중 제품·route·배포 요구에 따라 선택 | 허용 |
| **FTS-05** | Application | application 기반·framework | React SPA 기본, Next.js 허용; `FTS-04` 호환성 규칙 적용 | 기본·허용 |
| **FTS-06** | Application | router | React SPA는 React Router 또는 TanStack Router 중 선택, Next.js는 App Router | 허용 |
| **FTS-07** | Build | build·dev tool | React SPA는 Vite, Next.js는 Next.js 내장 build·dev tool | 기본·허용 |
| **FTS-08** | Package | package manager·lockfile | pnpm (`pnpm-lock.yaml`) | 기본 |
| **FTS-09** | Package | workspace·monorepo tool | pnpm workspace 기본, Turborepo 또는 Nx 병행 가능 | 기본·허용 |
| **FTS-10** | UI | styling | Tailwind CSS, CSS Modules, Vanilla CSS 중 프로젝트별 선택 | 허용 |
| **FTS-11** | UI | design system·component library | [빅밸류 디자인 시스템](https://design.bigvalue.ai/), shadcn/ui, Radix UI, MUI, Vanilla React Component 중 프로젝트별 선택 | 허용 |
| **FTS-12** | UI | component 문서·workshop | Storybook, Ladle 또는 별도 도구 없음 중 프로젝트별 선택 | 허용 |
| **FTS-13** | State | client state | Zustand, Jotai, React 기본 상태와 Context 중 프로젝트별 선택 | 허용 |
| **FTS-14** | State | server state·cache | React SPA는 TanStack Query 기본, Next.js server data는 Next.js `fetch`를 사용하되 cache·revalidation 정책을 명시하고 client cache가 필요할 때 TanStack Query 허용 | 기본·허용 |
| **FTS-15** | Data | API client·contract | Next.js server boundary는 `fetch` 기본, browser·client boundary는 `fetch`, Axios, Ky 중 프로젝트별 선택 | 기본·허용 |
| **FTS-16** | Data | schema·runtime validation | Zod | 기본 |
| **FTS-17** | Data | form state·validation | TanStack Form, Formik, React 기본 상태와 Zod 조합, 별도 도구 없음 중 프로젝트별 선택 | 허용 |
| **FTS-18** | Verification | lint·format·static analysis | ESLint와 Prettier 조합, Biome, TypeScript compiler 검사 중 프로젝트별 선택 | 허용 |
| **FTS-19** | Verification | unit·component test | Vitest와 React Testing Library 조합 | 기본 |
| **FTS-20** | Verification | integration·E2E test | Playwright | 기본 |
| **FTS-21** | Verification | visual·accessibility 검증 | Playwright screenshot, Chromatic, axe-core 중 프로젝트별 선택 | 허용 |
| **FTS-22** | Delivery | CI/CD | GitHub Actions, GitLab CI 또는 프로젝트별 임의 선택 | 허용 |
| **FTS-23** | Delivery | hosting·deployment runtime | 사내 인프라 기본, 프로젝트별 선택 가능하되 `FTS-04`의 rendering runtime·cache·revalidation 요구를 지원해야 함 | 기본·허용 |
| **FTS-24** | Operations | observability·error reporting | 프로젝트별 임의 선택 또는 미사용 | 허용 |
| **FTS-25** | Operations | analytics·feature flag | 프로젝트별 임의 선택 또는 미사용 | 허용 |
| **FTS-26** | Map | 지도 기능·지도 엔진 | 지도 필요 여부를 먼저 확인하고, 필요하면 MapLibre GL JS, OpenLayers, NAVER Maps API 중 하나를 선택 | 허용 |

### 작성 순서

1. `FTS-01`부터 ID 순서대로 진행하되, 아직 `미결정`인 항목 하나만 질문합니다.
2. `FTS-04`에서는 framework 이름을 먼저 묻지 않습니다. 공개 검색 노출, 초기 응답, 개인화, 데이터 갱신, cache·revalidation, 정적 배포 가능성, server·edge runtime 제약을 확인한 뒤 rendering 전략을 먼저 확정합니다.
3. `hybrid`를 선택하면 CSR·SSR·SSG·ISR 중 어떤 방식을 어느 route 또는 route 묶음에 적용하는지 먼저 확정합니다. Route별 소유자가 없는 `hybrid` 한 단어만으로는 `FTS-04`가 해소되지 않습니다.
4. `FTS-05`에서 React 자체와 Next.js를 양자택일로 표현하지 않습니다. `React SPA`와 React 기반 framework인 `Next.js` 중 application 기반을 선택합니다.
5. 답을 받으면 프로젝트 선택과 근거를 기록하고 다음 `미결정` 항목 하나를 질문합니다. `FTS-06`, `FTS-07`, `FTS-14`, `FTS-15`, `FTS-23`은 아래 호환성 규칙으로 허용 범위를 좁히되 각 행의 프로젝트 선택과 근거는 따로 기록합니다.
6. `FTS-26`은 지도 요청이 명시되지 않았더라도 사용자 또는 적용되는 Context가 이미 답하지 않았다면 먼저 `이 프로젝트에 지도 기능이 필요한가요?`라고 질문합니다. 필요하지 않으면 이유와 함께 `해당 없음`으로 확정합니다. 필요하면 다음 질문에서 MapLibre GL JS, OpenLayers, NAVER Maps API 중 하나만 선택받습니다.
7. 앞선 선택에서 문서화되지 않은 결합 관계를 임의로 추론하지 않습니다. 아래 표에 명시된 호환성은 추론이 아니라 Baseline 규칙으로 적용합니다.

### Rendering·application 호환성 규칙

Rendering 용어는 다음 의미로 사용합니다.

- **CSR:** browser에서 application shell과 화면을 주로 rendering합니다.
- **SSR:** 요청 시 server runtime이 HTML을 rendering합니다.
- **SSG:** build 시 HTML을 생성합니다.
- **ISR:** 미리 생성된 결과를 배포 후 정해진 조건이나 주기에 따라 재생성합니다.
- **hybrid:** route별로 CSR·SSR·SSG·ISR 중 둘 이상을 명시적으로 조합합니다.

현재 Baseline이 허용하는 조합은 다음과 같습니다.

| Rendering 선택 | Application 기반 | Router | Build·dev | Hosting·runtime 최소 조건 |
| --- | --- | --- | --- | --- |
| CSR | React SPA 기본, Next.js 허용 | React SPA는 React Router·TanStack Router 중 선택, Next.js는 App Router | React SPA는 Vite, Next.js는 내장 build·dev | 정적 hosting 가능; Next.js server 기능을 쓰면 해당 runtime 필요 |
| SSR | Next.js | App Router | Next.js 내장 build·dev | 요청 시 rendering 가능한 server 또는 edge runtime 필요 |
| SSG | Next.js | App Router | Next.js 내장 build·dev | 정적 hosting 가능하되 선택 기능이 server runtime을 요구하는지 별도 확인 |
| ISR | Next.js | App Router | Next.js 내장 build·dev | Node.js runtime과 재생성·cache 무효화를 지원하는 storage 필요; static export·edge-only 배포 불가 |
| hybrid | Next.js | App Router | Next.js 내장 build·dev | Route 표에 선택된 모든 rendering 방식의 runtime·cache·revalidation 조건을 충족하고 ISR route는 Node.js runtime에 배치해야 함 |

호환성 적용 규칙:

1. CSR을 선택하면 React SPA를 기본으로 사용합니다. 사용자가 Next.js 기능이나 향후 route-level rendering 필요를 구체적으로 선택한 경우 Next.js를 허용합니다.
2. SSR·SSG·ISR·hybrid를 선택하면 현재 Baseline에서는 Next.js를 사용합니다. React SPA에 임의의 SSR·SSG 도구를 추가하지 않습니다.
3. Next.js를 선택하면 App Router와 Next.js 내장 build·dev tool이 해당 역할을 소유합니다. React Router, TanStack Router 또는 Vite를 같은 application 역할에 추가하지 않습니다.
4. React SPA는 TanStack Query를 server-state·client cache 기본 소유자로 사용합니다. Next.js server data는 Next.js `fetch`를 사용하되 cache를 기본 활성화됐다고 가정하지 않고 route·data 요구에 따라 `cache`, `revalidate`, tag 또는 명시적 무캐시 정책과 소유자를 기록합니다. Client에서 독립적인 server-state cache가 실제로 필요한 범위에만 TanStack Query를 추가합니다.
5. Next.js server boundary는 `fetch`를 기본 API client로 사용합니다. Axios나 Ky는 browser·client boundary 또는 명시된 계약 기능이 필요하고 실제로 import·구성되는 경우에만 선택합니다.
6. Static-only hosting은 CSR과 호환되며, SSG는 선택한 Next.js 기능이 static output을 지원할 때만 호환됩니다. SSR·ISR 또는 이를 포함한 hybrid는 해당 실행·cache·revalidation 기능이 없는 static-only hosting과 호환되지 않습니다. ISR route는 Node.js runtime 및 배포 대상의 재검증 지원을 요구하므로 edge-only runtime과도 호환되지 않습니다.
7. Application 기반을 선택했다고 실제 rendering 방식이 자동으로 증명되지는 않습니다. Next.js 프로젝트도 각 route의 rendering, cache, revalidation 및 runtime 근거를 Context와 구성에서 확인해야 합니다.
8. 허용 조합을 벗어나거나 hosting 조건을 충족하지 못하면 스캐폴딩하지 않고 정확한 충돌과 필요한 조직 결정을 보고합니다.

### 지도 엔진 호환성 규칙

1. `FTS-26`은 `필요 여부`와, 필요한 경우의 `단일 지도 엔진`을 차례로 확정합니다. 지도 기능이 필요 없으면 지도 package, script, credential 또는 예제 코드를 추가하지 않습니다.
2. MapLibre GL JS, OpenLayers, NAVER Maps API는 현재 Baseline에서 같은 지도 rendering 역할의 대안입니다. Migration이나 분리된 surface 경계가 결정으로 문서화되지 않았다면 둘 이상을 함께 설치하지 않습니다.
3. MapLibre GL JS와 OpenLayers의 선택은 tile·style·공간 데이터·검색·geocoding 공급자 선택을 대신하지 않습니다. NAVER Maps API를 선택하면 NAVER 지도 플랫폼과 browser client 식별자 계약이 함께 적용되지만, 별도 공간 데이터·검색·geocoding API나 선택적 submodule까지 자동으로 선택된 것은 아닙니다. 실제로 필요한 provider·submodule과 계약, 출처, attribution, credential 및 사용량 제한은 `system.md`와 `security.md`에 별도로 기록합니다.
4. Interactive map은 browser 기능입니다. React SPA에서는 browser application 경계가 소유하고, Next.js에서는 map component를 client boundary에 두어 server rendering 중 `window`, `document`, WebGL 또는 provider browser SDK에 접근하지 않습니다. Page의 SSR·SSG·ISR 선택 자체를 지도 때문에 CSR로 바꾸지는 않습니다.
5. 지도 instance, event listener, observer 및 request의 생성·갱신·해제 소유자를 하나로 두고 unmount 또는 route 전환 시 정리합니다.
6. 지원 browser, WebGL·Canvas 요구, credential 공개 범위, 허용 domain, 위치정보와 사용자 입력 처리 및 외부 지도 데이터의 신뢰 경계를 선택한 engine·provider 기준으로 검증합니다.

## 정본과 책임

- **Baseline이 소유:** 조직 기본 기술, 허용 대안, 금지 기술, 최소·권장 버전 정책, 지원 수명과 종료 조건, 호환성 제약, 도입·예외·교체 절차
- **프로젝트 Context가 소유:** 실제 기술과 버전, 선택 이유, 적용 범위, 설정·manifest·lockfile 위치, 실행 명령, 배포 환경, Baseline과의 편차, 검증 근거
- **코드와 자동화가 제공하는 근거:** manifest, lockfile, compiler·build·test 설정, CI workflow, 배포 설정과 실제 실행 결과

Context는 Baseline의 설명을 복사하지 않습니다. 적용되는 조직 기준을 참조하고 프로젝트가 해소한 선택과 편차만 기록합니다. 문서, manifest, lockfile, CI가 서로 다르면 추정으로 합치지 않고 `문서-코드 불일치`로 보고합니다.

## 기술 스택 분류

| 영역 | Baseline이 정해야 하는 조직 기준 | 프로젝트 Context가 답해야 하는 실제 값 |
| --- | --- | --- |
| **실행 환경** | 지원 브라우저 정책, frontend toolchain용 runtime 정책, CSR·SSR·SSG·ISR·hybrid·edge 적용 범위, 지원 종료 원칙 | target browser, toolchain·server runtime과 버전, route별 rendering 방식, polyfill, hosting·cache·revalidation 제약 |
| **언어·타입** | 기본 언어, module 체계, type safety와 compiler strictness의 최소선, 생성 코드 취급 | 사용 언어, compiler 설정, 예외 범위, type generation 원본과 명령 |
| **Application 기반** | rendering별 기본 application 기반, 허용 대안과 선택 조건, router·build·rendering 책임의 경계 | React SPA 또는 Next.js와 버전, router·build 소유자, 기본 및 route별 rendering, entry point와 route 정본 |
| **Build·개발 환경** | 표준 build/dev tool 역할, 환경 변수 주입 원칙, production build의 재현 조건 | build tool·plugin과 버전, dev server, 환경별 설정, install·dev·build·preview 명령 |
| **Package·dependency** | 표준 package manager, lockfile·workspace·registry 정책, dependency 도입·갱신·폐기 기준 | package manager와 버전, 정본 lockfile, workspace 경계, registry 설정, update 명령 |
| **UI·Design System** | 공용 design system, token·component·icon·font·styling의 기본 소유권과 허용 확장 방식 | 적용한 library·token source, project component 경계, theme·responsive·accessibility 설정 |
| **지도·공간 UI** | 지도 필요 여부, 허용 지도 엔진, browser·rendering 경계, provider 분리와 도입 조건 | 선택한 지도 엔진과 version, component·lifecycle 소유자, tile·data·검색 provider, attribution, credential·domain 및 검증 근거 |
| **State·Data** | server·client·URL·form 상태의 기본 소유 원칙, API client·schema validation·cache 사용 기준 | 상태·form·data library와 버전, API 경계, cache key·invalidating·retry·cancellation 소유자 |
| **검증** | typecheck, lint, format, unit, integration, E2E, visual, accessibility, 성능 검증의 최소 조합과 CI·운영 gate | 실제 도구와 설정, test 위치, 단일·전체 실행 명령, 기대값과 fixture·snapshot 정본, 품질 gate의 범위·통과 조건·예외 소유자와 만료, 주요 route·흐름의 lab·field 성능 budget과 측정 근거 |
| **배포·운영** | artifact, CI/CD, observability, error reporting, analytics, feature flag의 승인 범위와 보안 원칙 | build artifact, 배포 대상, pipeline, 환경 승격, source map, monitoring과 rollback 경로 |

이 분류는 도구를 늘리기 위한 체크리스트가 아닙니다. 적용되지 않는 영역은 근거와 함께 `해당 없음`으로 두고, 여러 도구가 같은 역할을 맡으면 각각의 소유 범위와 제거·전환 계획을 밝혀야 합니다.

## 조직 스택 항목의 필수 정보

Baseline에서 기술을 기본값이나 허용 대안으로 선언할 때는 다음 정보를 함께 기록합니다.

- 기술 이름과 담당 역할
- 상태: `기본`, `허용`, `예외`, `금지`, `교체 예정`, `지원 종료`
- 지원 version 범위와 version 고정·갱신 방식
- 적용 범위와 선택 조건
- 표준 소유 팀 또는 책임자와 결정 근거
- 함께 사용할 수 없거나 반드시 함께 써야 하는 기술
- 도입·upgrade·migration·rollback 검증 방법
- 대체 기술, 전환 기한, 지원 종료 이후의 처리

제품명만 나열한 목록은 기술 스택 정본이 아닙니다. 역할, 상태, version 정책, 적용 범위, 소유자, 검증과 수명 주기가 있어야 조직 기준으로 사용할 수 있습니다.

## 프로젝트 적용 규칙

1. 각 프로젝트는 적용되는 Baseline version 또는 정본 위치와 실제 스택을 연결한 표를 Context에 둡니다.
2. 역할별로 하나의 기본 소유 기술을 정합니다. 같은 역할의 기술이 둘 이상이면 경계, 전환 순서, 제거 조건을 기록합니다.
3. 조직 기본값 밖의 기술을 도입할 때는 Decisions에 이유, 검토한 대안, 영향 범위, 소유자, 검증, migration·철회 조건을 남깁니다.
4. major version, rendering 방식, framework, package manager, public contract처럼 파급이 큰 변경은 호환성, consumer 전환, 배포와 rollback을 함께 결정합니다.
5. version과 실행 명령은 기억이나 전역 설치에 의존하지 않고 manifest, lockfile, 설정, CI에서 재현할 수 있어야 합니다.
6. 교체 예정 또는 지원 종료 기술은 신규 사용 가능 여부, 기존 프로젝트 지원 기한, 목표 기술과 완료 조건을 명시합니다.
7. 기술 선택이 비밀값, 외부 값 검증, 상태 소유권, cleanup, 계약, UX 상태, 검증 경계를 약화시키는 예외가 될 수 없습니다.
8. MapLibre GL JS·OpenLayers의 지도 엔진과 지도 데이터·tile·검색·geocoding 공급자는 서로 다른 역할로 기록합니다. NAVER Maps API는 결합된 NAVER 지도 플랫폼 범위와 별도 API·submodule 범위를 구분합니다. 지도 기능이 필요 없으면 `FTS-26`을 `해당 없음`으로 남기고 관련 의존성을 설치하지 않습니다.

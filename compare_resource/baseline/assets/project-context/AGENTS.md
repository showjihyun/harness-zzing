# 프로젝트 에이전트 지침

## Context 인덱스

Context 문서는 `{{CONTEXT_폴더}}/`에 있습니다. 계획하거나 편집하기 전에 `{{CONTEXT_폴더}}/software.md`를 읽고, 아래 조건과 일치하는 모든 문서를 추가로 읽습니다. 읽기 조건은 누적되며 영향을 받는 consumer와 의존성도 같은 방식으로 따라갑니다.

| 문서 | 정본으로 소유하는 내용 | 읽기 조건 |
| --- | --- | --- |
| `{{CONTEXT_폴더}}/prd.md` | 제품 목적, 사용자, 요구사항, acceptance criteria, 핵심 흐름, 지도 필요성 | 제품 동작, 사용자 흐름, 요구사항, 지도 필요 여부 또는 범위 변경 |
| `{{CONTEXT_폴더}}/domain.md` | 도메인 용어, 비즈니스 규칙, 불변 조건, 권한 정책 | 도메인 의미, 규칙 또는 권한 변경 |
| `{{CONTEXT_폴더}}/data-model.md` | Entity, schema, 관계, validation, 영속성, migration | 데이터 구조, 계약 또는 저장 방식 변경 |
| `{{CONTEXT_폴더}}/ui-ux.md` | 화면 구조, 상호작용 상태, 반응형, 접근성, 지도 UI, UI·사용자 체감 성능 기대값 | 사용자에게 보이는 동작, 지도 interaction, UI 또는 체감 성능 목표 변경 |
| `{{CONTEXT_폴더}}/software.md` | Rendering, application 기반, 기술 스택, 지도 engine·client boundary, 명령어, 컴포넌트·모듈·비즈니스 규칙 소유권, 공개 surface·의존성, route, 상태·cache 소유권, 코드 품질·성능 기준·gate·예외 | 모든 작업 및 소프트웨어 구현·설계·성능·품질 변경 |
| `{{CONTEXT_폴더}}/system.md` | Runtime, rendering·hosting 호환성, 지도 provider·공간 데이터, 외부 시스템, API, 인증, 환경 변수, 운영 성능 측정·경보, 배포 | 외부 연동, 지도 provider·공간 데이터, 신뢰 경계, rendering, cache·revalidation, field 성능, runtime 또는 배포 변경 |
| `{{CONTEXT_폴더}}/security.md` | 보호 자산, 위협·오용, 지도 credential·외부 입력, 보안 경계, 신뢰하지 않는 콘텐츠·XSS 방어, 비밀값, 공급망, 보안 통제·취약점·예외·검증 | 인증·권한·지도·외부 입력·콘텐츠 출력·raw HTML·DOM·비밀값·의존성 또는 보안 영향 변경 |
| `{{CONTEXT_폴더}}/decision.md` | 지속되는 결정, 대안, 결과, 대체 이력 | 되돌리기 어려운 선택 또는 기존 결정 변경 |

## 작업 규칙

- Context를 프로젝트 규칙과 결정의 소유자로, 코드·구성·CI·명령어 출력을 현재 상태의 근거로 취급합니다.
- Context와 구현이 다르면 어느 한쪽을 조용히 선택하지 않습니다. 불일치를 보존하고 작업 범위 안에서 해결하거나 보고합니다.
- 변경으로 프로젝트 규칙, 지속되는 결정, 명령어, 계약 또는 검증된 현재 상태가 달라지면 이를 소유하는 Context 문서를 갱신합니다.
- `{{CONTEXT_폴더}}/software.md`, `{{CONTEXT_폴더}}/system.md`, `{{CONTEXT_폴더}}/security.md`의 적용되는 검증 명령어를 실행합니다. 실제로 실행한 검사만 보고하고, 통과 결과를 얻기 위해 gate를 약화하지 않으며 제외·우회에는 소유자와 만료 조건을 둡니다.
- 사용자 변경을 보존하고 관련 없는 작업을 범위에 포함하지 않습니다.

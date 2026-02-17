# 🛡️ Universal Testing Protocol (UTP) v2.0

이 문서는 모든 프로젝트의 품질 보장 및 자동화된 배포 안정성을 위한 전사적 테스트 표준입니다.

## 1. 테스트 철학 (Philosophy)
1. **TDAI (Test-Driven AI):** 코드를 짜기 전, 무엇을 테스트할지 '테스트 플랜'을 먼저 제안한다.
2. **Confidence over Coverage:** 기능이 의도대로 작동하는가에 대한 '확신'에 집중한다.
3. **Automated Verification:** 모든 검증은 로컬 환경뿐만 아니라 CI 파이프라인에서도 동일하게 수행되어야 한다.
4. **No Regression:** 수정 시 반드시 기존 테스트를 실행하여 퇴보가 없음을 증명한다.

## 2. 권장 기술 스택 (Standard Stack)
- **Logic/Unit:** Vitest
- **UI/Integration:** React Testing Library, MSW
- **E2E (End-to-End):** Playwright (핵심 사용자 시나리오 검증용)
- **CI/CD:** GitHub Actions (Test + Build 자동화)

## 3. AI 실행 지침 (Instructions for AI)

### 3.1 초기 환경 구축 (Project Setup)
- 프로젝트 시작 시, 반드시 `.github/workflows/ci.yml` 파일을 생성하여 **테스트 및 빌드 자동화 파이프라인**을 구축하라.
- `package.json`에 `test`, `test:coverage`, `build` 스크립트가 올바르게 설정되었는지 확인하라.

### 3.2 테스트 작성 및 수행
- **신규 기능:** 기능 코드, 유닛 테스트, 그리고 핵심 경로에 대한 **E2E 테스트(Playwright)**를 한 번에 제출할 것.
- **E2E 우선순위:** 사용자의 'Happy Path'(가장 중요한 핵심 경험)에 대해 최소 1개 이상의 Playwright 시나리오를 작성하라.
- **버그 수정:** 버그 재현 테스트를 먼저 작성하고, 이를 통과시키는 코드를 작성할 것.
- **AAA 패턴 준수:** 모든 테스트는 Arrange(준비), Act(실행), Assert(검증) 단계를 따를 것.

### 3.3 CI 연동 및 빌드 확인
- 코드를 수정하거나 기능을 추가한 후에는 반드시 로컬에서 `npm run build`를 실행하여 빌드 에러가 없는지 확인하라.
- GitHub Actions 환경에서 테스트가 실패할 가능성이 있는 요소(환경변수 등)를 사전에 체크하라.

## 4. 완료 정의 (Definition of Done)
- [ ] 모든 신규 로직에 대한 단위 테스트가 존재하는가?
- [ ] 핵심 사용자 시나리오에 대한 E2E 테스트(Playwright)가 통과하는가?
- [ ] GitHub Actions CI 워크플로우 파일이 존재하고 정상 작동하는가?
- [ ] `npm run build`가 에러 없이 성공하는가?

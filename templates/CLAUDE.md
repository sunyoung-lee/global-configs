# Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

# Testing Standard

모든 프로젝트에서 `~/Testing_Standard.md` 문서를 반드시 읽고 준수하라. 테스트 통과 로그가 없는 코드는 제출하지 마라.

---

# WSA LAB Design System (v8.0)

이 프로젝트의 디자인 스타일 가이드. 모든 UI 작업 시 아래 토큰과 유틸리티 클래스를 우선 사용할 것.

## 컬러 토큰

### 라이트 모드
| 토큰 | 값 | 용도 |
|------|-----|------|
| `--color-base-bg` | `#FAFAFA` | 페이지 배경 |
| `--color-base-text` | `#1A1A1A` | 본문 텍스트 |
| `--color-accent` | `#2563EB` | 강조/링크 |
| `--color-secondary` | `#6B7280` | 보조 텍스트 |
| `--color-border` | `#E5E7EB` | 구분선/테두리 |
| `--color-surface` | `#F3F4F6` | 카드/서피스 |
| `--color-hover` | `#F9FAFB` | 호버 상태 |

### 다크 모드 (Deep Midnight Laboratory)
| 토큰 | 값 | 용도 |
|------|-----|------|
| `--color-base-bg` | `#030108` | 자주빛 근흑 배경 |
| `--color-base-text` | `#E8ECF4` | 본문 텍스트 |
| `--color-accent` | `#00E5FF` | 사이안 네온 강조 |
| `--color-secondary` | `#7B8CA8` | 보조 텍스트 |
| `--color-border` | `rgba(0, 229, 255, 0.08)` | 사이안 미세 테두리 |
| `--color-surface` | `#060A14` | 남색 서피스 |
| `--color-hover` | `#080D1A` | 호버 상태 |
| `--color-glow` | `rgba(0, 229, 255, 0.15)` | 글로우 이펙트 |
| `--color-glow-strong` | `rgba(0, 229, 255, 0.35)` | 강한 글로우 |

## 서체

- **Sans**: `var(--font-inter)`, "Pretendard Variable", Pretendard, sans-serif
- **Mono**: `var(--font-jetbrains)`, "JetBrains Mono", "SF Mono", "Fira Code", monospace
- **본문**: `line-height: 1.6`, `letter-spacing: -0.01em`
- **제목**: `letter-spacing: -0.02em`

## 핵심 CSS 유틸리티 클래스

### `.blueprint-grid`
엔지니어링 페이퍼 패턴. 40px 간격 사이안 격자선. 전체 레이아웃 배경에 사용.

### `.lab-card`
강화된 글래스모피즘 카드.
- 라이트: `background: rgba(255,255,255,0.06)`, 미세 테두리
- 다크: `backdrop-filter: blur(24px) saturate(200%)`, 사이안 테두리, 3중 box-shadow, inset 하이라이트

### `.neon-cyan`
네온 텍스트 글로우.
- 라이트: `color: #2563EB`
- 다크: `color: #00E5FF` + 3중 text-shadow (10px/30px/60px glow)

### `.hero-score`
대형 점수 타이포그래피. `font-mono`, `4rem`, `font-weight: 800`, `letter-spacing: -0.04em`

### `.scan-line`
수평 레이저 스윕 애니메이션. 사이안 그라데이션, 2초 주기, `pointer-events: none`

### `.code-rain-bg`
매트릭스 스타일 이진코드 열 배경. `::before`/`::after` 수직 텍스트, 8초 폴.

### `.code-rain-text`
항목 진입 애니메이션. blur(4px) → blur(0) + translateY(-8px→0), 0.4초.

### `.btn-shiny`
호버 시 하이라이트 스윕. `::after` pseudo-element, skewX(-15deg), 0.6초.

### `.glow-accent`
사이안 글로우 box-shadow. 다크 모드에서 이중 레이어 (30px + 60px).

## 다크 모드 배경

메시 그라데이션 (background-attachment: fixed):
- 사이안 ellipse (15% 50%, 6% opacity)
- 인디고 ellipse (85% 15%, 5% opacity)
- 틸 ellipse (50% 90%, 3% opacity)
- 슬레이트 ellipse (중앙, 80% opacity)
- 베이스: `#030108`

## 다크 모드 규칙

- Tailwind v4 + next-themes: `@custom-variant dark (&:where(.dark, .dark *));` 필수
- `prefers-color-scheme` 미디어 쿼리 사용 금지 — `.dark` 클래스 전략만 사용
- 다크 모드 색상은 반드시 토큰 참조 또는 `dark:` prefix 사용

## 브랜드 아이덴티티

- 로고: **WSA** (Extra Bold, `neon-cyan`, JetBrains Mono) + **LAB** (소형 뱃지, `border-cyan/20`)
- 컨셉: "하이테크 실험실의 대시보드" — 정밀 기계로 웹사이트 유전자를 스캔하는 느낌
- 카피: 한국어 실험실 용어 (유전자, 추출, 설계, 매니페스토, 싱크 분석)

## 애니메이션 원칙

- framer-motion v12 사용 (AnimatePresence, motion.div)
- 진입: staggerChildren 0.04s, opacity 0→1, y 8→0
- 카운팅: requestAnimationFrame + cubic ease-out
- 타이프라이터: setInterval 8ms 문자 순차 표시
- 코드레인: 수직 이진코드 열, opacity 0.06~0.15
- 스캔 라인: 사이안 레이저 수평 스윕

## 컴포넌트 스타일 규칙

1. **카드/패널**: `lab-card` 클래스 우선 사용, 개별 backdrop-filter 지양
2. **강조 텍스트**: `neon-cyan` 클래스, 직접 color 지정 지양
3. **테두리**: 다크 모드에서 `dark:border-[#00E5FF]/8` 패턴
4. **호버**: `dark:hover:bg-white/5` 통일
5. **폰트 크기 체계**: 9px(라벨) / 10px(캡션) / 11px(모노 데이터) / 12px(본문) / 14px(소제목)
6. **차트**: Recharts 사용, 다크 모드 cyan 계열 색상
7. **빈 상태**: 한국어 안내 문구 + `neon-cyan` 아이콘

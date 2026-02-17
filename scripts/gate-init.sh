#!/bin/bash
# 테스트 게이트 및 표준 설정을 현재 프로젝트에 설치합니다.
# 사용법: 프로젝트 루트에서 ~/global_configs/scripts/gate-init.sh 실행

set -e

echo "🔧 Gate Init: 테스트 게이트를 설치합니다..."

# 1. Testing_Standard.md 심볼릭 링크
ln -sf ~/global_configs/templates/Testing_Standard.md ./Testing_Standard.md
echo "  ✅ Testing_Standard.md linked"

# 2. Husky + lint-staged 설치 (없는 경우)
if [ ! -d ".husky" ]; then
  npx husky init
  echo "npx lint-staged" > .husky/pre-commit
  echo "  ✅ Husky initialized with pre-commit hook"
else
  echo "  ⏭️  Husky already exists, skipping"
fi

if ! grep -q '"lint-staged"' package.json 2>/dev/null; then
  npm install -D lint-staged
  echo "  ✅ lint-staged installed"
else
  echo "  ⏭️  lint-staged already in package.json, skipping"
fi

echo ""
echo "✅ All gates deployed! Commits will now require passing tests."

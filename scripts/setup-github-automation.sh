#!/bin/bash
# 모든 GitHub repo에 Dependabot alerts를 일괄 활성화합니다.
# 사용법: ~/global_configs/scripts/setup-github-automation.sh

set -e

USER=$(gh api user --jq '.login')
echo "🔧 GitHub Automation: $USER 의 모든 repo에 Dependabot을 활성화합니다..."
echo ""

gh repo list "$USER" --limit 100 --json name -q '.[].name' | while read -r repo; do
  if gh api -X PUT "repos/$USER/$repo/vulnerability-alerts" 2>/dev/null; then
    echo "  ✅ $repo: Dependabot alerts enabled"
  else
    echo "  ⚠️  $repo: skipped (may require admin access)"
  fi
done

echo ""
echo "✅ Done! Dependabot alerts activated for all accessible repos."

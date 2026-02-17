#!/bin/bash
# 이 스크립트를 실행하면 전역 설정들을 현재 프로젝트에 연결합니다.

# 1. 테스트 게이트 설치 실행
~/global_configs/scripts/gate-init.sh

# 2. 공통 설정 파일 심볼릭 링크 (예: .prettierrc)
# ln -sf ~/global_configs/configs/.prettierrc ./.prettierrc

echo "✅ All global configs & gates have been deployed to this project!"

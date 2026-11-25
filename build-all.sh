#!/usr/bin/env bash
# 一键：标准 hvigor 构建 HAP -> 签名安装（第一阶段：纯 UI，无 native .so）
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

CLT="${CELLAR_CLT:-/opt/electron-ohos-clt}"
[ -d "$CLT" ] || CLT="$HOME/HarmonyPC/Myspace/build-test/electron-ohos-clt"
SDK="${CELLAR_SDK:-$CLT/sdk}"
HVIGOR="${CELLAR_HVIGOR:-$CLT/hvigor/bin/hvigorw}"
SP="${CELLAR_SIGN_PROJECT:-$HOME/.app-installer/projects/com.social4hyq.cellar}"

export DEVECO_SDK_HOME="$SDK" HOS_SDK_HOME="$SDK" OHOS_BASE_SDK_HOME="$SDK"

echo "==> [1/2] hvigor 构建 HAP"
bash "$HVIGOR" --mode module -p product=default assembleHap --no-daemon

HAP="$HERE/entry/build/default/outputs/default/entry-default-unsigned.hap"

echo "==> [2/2] 签名安装"
mkdir -p "$HERE/dist"
app-installer install --hap "$HAP" \
  --bundle-id com.social4hyq.cellar --app-name Cellar \
  --module entry --ability EntryAbility \
  --profile "$SP/build-profile.json5" \
  --signed-hap "$HERE/dist/cellar-signed.hap"

echo "DONE. HAP size: $(du -h "$HAP" | cut -f1)"

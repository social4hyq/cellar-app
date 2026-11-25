#!/usr/bin/env bash
# 一键：编译 native .so -> hvigor 构建 HAP -> 注入 .so -> 签名安装
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

CLT="${CELLAR_CLT:-/opt/electron-ohos-clt}"
[ -d "$CLT" ] || CLT="$HOME/HarmonyPC/Myspace/build-test/electron-ohos-clt"
SDK="${CELLAR_SDK:-$CLT/sdk}"
HVIGOR="${CELLAR_HVIGOR:-$CLT/hvigor/bin/hvigorw}"
SP="${CELLAR_SIGN_PROJECT:-$HOME/.app-installer/projects/com.social4hyq.cellar}"

export DEVECO_SDK_HOME="$SDK" HOS_SDK_HOME="$SDK" OHOS_BASE_SDK_HOME="$SDK"

echo "==> [1/4] 编译 native .so"
bash build-so.sh

echo "==> [2/4] hvigor 构建 HAP"
bash "$HVIGOR" --mode module -p product=default assembleHap --no-daemon

HAP="$HERE/entry/build/default/outputs/default/entry-default-unsigned.hap"
SO_DIR="$HERE/entry/src/main/cpp/libs/arm64-v8a"

echo "==> [3/4] 注入 .so 到 HAP"
STAGE=/data/storage/el2/base/cache/cellar-so-stage
rm -rf "$STAGE"; mkdir -p "$STAGE/libs/arm64-v8a"
found=0
for so in "$SO_DIR"/*.so; do
  [ -f "$so" ] || continue
  cp "$so" "$STAGE/libs/arm64-v8a/"
  found=$((found + 1)); echo "    + $(basename "$so")"
done
[ "$found" -gt 0 ] || { echo "ERROR: no .so found" >&2; exit 1; }
zip -q -d "$HAP" 'libs/*' 2>/dev/null || true
(cd "$STAGE" && zip -q -r "$HAP" libs)

echo "==> [4/4] 签名安装"
mkdir -p "$HERE/dist"
app-installer install --hap "$HAP" \
  --bundle-id com.social4hyq.cellar --app-name Cellar \
  --module entry --ability EntryAbility \
  --profile "$SP/build-profile.json5" \
  --signed-hap "$HERE/dist/cellar-signed.hap"

echo "DONE. HAP size: $(du -h "$HAP" | cut -f1)"

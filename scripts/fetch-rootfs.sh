#!/bin/sh
# 从 aarch64 包仓库拉取启元基础根文件系统并解包到目标目录
# 用法: ./fetch-rootfs.sh [目标目录] [包名...]
set -e
BASE=https://github.com/Quor-a/qiyuan-linux-aarch64/releases/latest/download
DEST=${1:-$HOME/qyroot}
shift 2>/dev/null || true
PKGS="${*:-busybox-1.36.1-1.aarch64.qyp}"

mkdir -p "$DEST" && cd "$DEST"
for p in $PKGS; do
  echo "==> 下载 $p"
  curl -fLO "$BASE/$p"
  echo "==> 解包 $p"
  tar --zstd -xf "$p" && rm -f "$p"
done
echo "==> 完成。进入环境:"
echo "  proot -r $DEST -0 -b /dev -b /proc -b /sys /usr/bin/busybox sh"

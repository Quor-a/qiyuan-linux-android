#!/bin/sh
# 从 aarch64 包仓库拉取启元基础根文件系统并解包到目标目录
# 用法: ./fetch-rootfs.sh [目标目录] [包名...]
# 例:   ./fetch-rootfs.sh ~/qyroot busybox-1.36.1-1.aarch64.qyp ncurses-6.5-1.aarch64.qyp
set -e
BASE=https://github.com/Quor-a/qiyuan-linux-aarch64/releases/latest/download
DEST=${1:-$HOME/qyroot}
shift 2>/dev/null || true
PKGS="${*:-busybox-1.36.1-1.aarch64.qyp}"
DIR=$(cd "$(dirname "$0")" && pwd)

mkdir -p "$DEST" && cd "$DEST"
for p in $PKGS; do
  echo "==> 下载 $p"
  # -f 失败即停；--retry 抗网络抖动；-C - 断点续传（不要并发跑同一文件）
  curl -fL --retry 5 --retry-delay 2 -C - -o "$p" "$BASE/$p"
  echo "==> 解包 $p"
  sh "$DIR/qyextract.sh" "$p" && rm -f "$p"
done
echo "==> 完成。进入环境:"
echo "  proot -r $DEST -0 -b /dev -b /proc -b /sys /usr/bin/busybox sh"

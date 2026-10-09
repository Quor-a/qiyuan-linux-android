#!/system/bin/sh
# 已 root 安卓设备的 chroot 进入脚本（push 到设备后 su 运行）
set -e
ROOT=${1:-/data/qyroot}
[ -d "$ROOT" ] || { echo "根目录不存在: $ROOT"; exit 1; }
mountpoint -q "$ROOT/proc" || mount -t proc proc "$ROOT/proc"
mountpoint -q "$ROOT/sys"  || mount -t sysfs sys  "$ROOT/sys"
mountpoint -q "$ROOT/dev"  || mount -o bind /dev  "$ROOT/dev"
exec chroot "$ROOT" /usr/bin/busybox sh

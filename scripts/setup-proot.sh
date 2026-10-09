#!/data/data/com.termux/files/usr/bin/sh
# Termux 一键搭启元 proot 环境
set -e
command -v proot >/dev/null || pkg install -y proot
command -v curl  >/dev/null || pkg install -y curl
command -v zstd  >/dev/null || pkg install -y zstd
DIR=$(dirname "$0")
exec sh "$DIR/fetch-rootfs.sh" "$HOME/qyroot"

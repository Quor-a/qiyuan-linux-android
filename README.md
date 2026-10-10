# 启元 Linux · 安卓移植层

把**启元 Linux**（Quor-a/qiyuan-linux）的 aarch64 用户空间搬到安卓设备上运行。

安卓与普通 ARM64 Linux 的差别不在 CPU 指令（都是 aarch64），而在**用户空间接口**：
安卓用的是 bionic libc + 特有链接器，不是 glibc。本仓库提供三条落地路径。

## 三条路径

| 路径 | 需要 root | 原理 | 适用 |
|---|---|---|---|
| **A. proot** | 否 | ptrace 拦截系统调用，把路径重定向到目录 | 普通手机、快速试用 |
| **B. chroot** | 是 | 直接切根，性能最好 | 已 root 设备、开发板 |
| **C. 原生启动** | 是 | 刷 boot.img 启动启元内核 | 深度定制设备 |

三条路共用同一套 **aarch64 .qyp 包**：
https://github.com/Quor-a/qiyuan-linux-aarch64

## 快速开始（路径 A：proot，无需 root）

```sh
# 1. 在 Termux 里安装 proot
pkg install proot

# 2. 一键拉取并解包完整基础环境（glibc + busybox + bash + 常用工具，约 20 包）
curl -LO https://raw.githubusercontent.com/Quor-a/qiyuan-linux-android/main/scripts/setup-proot.sh
sh setup-proot.sh

# 或分步：下载包后用 qyextract.sh 解包（.qyp = 128 字节头 + gzip tar 数据段）
# sh qyextract.sh <包.qyp> [目标目录]

# 3. 进入启元环境
proot -r ~/qyroot -0 -b /dev -b /proc -b /sys /usr/bin/bash
```

进入后即是启元 Linux 的 aarch64 用户空间：glibc 运行时 + bash/grep/sed/tar 等。
注意：**glibc 包必须最先解包**（其余动态链接包都依赖它）。

## 路径 B：chroot（已 root）

```sh
su -c "
  mkdir -p /data/qyroot
  # 解包同上到 /data/qyroot
  mount -t proc proc /data/qyroot/proc
  mount -t sysfs sys /data/qyroot/sys
  chroot /data/qyroot /usr/bin/busybox sh
"
```

## 路径 C：原生启动（刷机）

主仓库的 `bin/qyandroid` 负责打包安卓引导镜像：

```sh
# 打包 boot.img（内核 + ramdisk + dtb）
python3 bin/qyandroid bootimg \
  --kernel Image.gz --ramdisk ramdisk.img --dtb board.dtb \
  --cmdline "console=ttyMSM0" --out boot.img

# 打包前自检（页大小/魔数/AVB 一致性——安卓刷错直接变砖）
python3 bin/qyandroid verify boot.img

# 生成 fastboot 刷机脚本（会明确警告解锁会清空数据）
python3 bin/qyandroid super --root-mb 3072
```

⚠️ **刷机风险**：解锁 bootloader 会**清空全部用户数据**，且各厂商解锁政策不同。
请先备份，并确认设备有可用的救砖手段（fastboot 镜像、官方固件包）。

## 已知限制

- 安卓的 **bionic libc** 与 glibc 不兼容：本仓库包是 glibc 目标（aarch64-linux-gnu），
  必须经 proot/chroot 提供 glibc 运行时，不能直接丢进安卓 `/system/bin`。
- verified boot 设备上 `/system` 只读，写入需 overlay 或改刷 GSI。
- 无 root 设备只能走路径 A（proot），性能约为原生 60–80%。

## 目录

- `scripts/setup-proot.sh` — 一键在 Termux 里搭好启元 proot 环境（约 20 包）
- `scripts/chroot-enter.sh` — 已 root 设备的 chroot 进入脚本
- `scripts/fetch-rootfs.sh` — 从包仓库拉取并解包基础根文件系统
- `scripts/qyextract.sh` — 解包单个 .qyp（解析 QYPKG 头 + 完整性校验）

## 相关仓库

- 主仓库（配方 + 源码 + 工具链）：https://github.com/Quor-a/qiyuan-linux
- aarch64 包仓库：https://github.com/Quor-a/qiyuan-linux-aarch64
- x86_64 包仓库：https://github.com/Quor-a/qiyuan-linux-pkgs

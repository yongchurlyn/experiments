## 问题描述

在嵌入式Linux研发的过程中，我们遇到了如下的问题，严重影响了研发效率：

* 硬件资源缺乏：七八个人排队眼巴巴的等着一两块单板来调试代码，特别是在打样阶段，板子不稳定、经常出问题，导致有时候甚至一块可用的单板都没有。

* 编译时间长：嵌入式Linux编译工程极为庞大(几十个G)，完整编译耗时4个小时以上；改动几行代码有可能也要经历漫长的编译过程，难以快速修改代码&验证有效性。

经过分析发现：

* 庞大的编译工程中，绝大部分的软件包都不会被修改，所以在研发阶段没有必要每次都构建出大而全的烧写包；

* 会对Linux内核进行一些定制修改，而这些修改大部分都是硬件无关的，所以可以尽量用软件模拟的方式去调试内核。

## 解决方法

如果打造一个轻量级的、面向个人的、在任何地方（在公司或者在家）都能使用的仿真开发环境，则能够解决这个问题；具体怎么做，有如下两种思路：

### 站在巨人的肩膀上，定制出一套仿真环境：

* 基于供应商的构建系统：每个芯片供应商都有自己的一套构建系统，支持该厂商多个序列的芯片，适合面向真实芯片的产品研发，代码中存在很多兼容性的特殊处理，改动不易，而且有商业产权。

* 基于开源已有的构建系统：可以利用开源yocto或者buildroot来定制出一套构建系统，但它们体量也很大，有各自的一套规则，存在学习曲线，大一点的公司甚至有专门的系统集成团队来做这件事情。

### 站在泥土上，从0开始打造一套仿真环境：

自己动手、丰衣足食，可以深入掌控每一个细节。

安装依赖包， 以ubuntu为例：

```
编译内核依赖于这些：
sudo apt install -y flex bison libssl-dev

编译systemd依赖于：
sudo apt install -y  meson  ninja-build pkg-config

```

#### 支持功能：
* 从0开始，交叉构建出一个可以运行的最小Linux操作系统；

* 支持对Linux内核进行定制修改；

* 支持按需增加所需要的软件包

#### 多个demo：
坚持“可以工作的软件胜过面面俱到的文档”的原则，提供了多个运行单独的实例：

* demo_01: 最小Linux系统变种1（Linux + 静态链接的Busybox，initramfs的形式） 
* demo_02: 最小Linux系统变种2（Linux + 静态链接Busybox，古老的initrd的形式，便于和demo_01进行对比）
* demo_03, 最小Linux系统变种3（Linux + glibc + 动态链接的Busybox） 
* demo_04: 最小Linux系统变种4（Linux + glibc + systemd， 切换了init） 
* demo_05: 最小Linux系统变种5（Linux + glibc + Busybox + gdb, 增加了调试工具)
* demo_06: 最小Linux系统变种6（Linux + glibc + Busybox + 定制化ko, diskimg的形式)
* demo_07: 最小Linux系统变种7（Linux + glibc + systemd, 按需新增了bash, util-linux, coreutil, elfutils等)
* demo_08: 最小Linux系统变种8（Linux + glibc + Busybox, 可以支持diagnose, opendds等)
* demo_09: 最小Linux系统变种9（Linux + glibc + Busybox, 可以支持其他sdk中的网络工具，例如iptables, ethtool等)

未完待续...




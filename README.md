# Cellar — Homebrew GUI for HarmonyOS

基于 [BrewUI](https://github.com/Homebrew/BrewUI) 界面设计的鸿蒙原生包管理 GUI。纯 ArkTS 实现，界面 1:1 复刻 BrewUI 的设计系统。

> 名称来源：Homebrew 的安装目录就叫 Cellar（酒窖）。

## 当前阶段：Phase 2 — 实时 brew 数据（P1）

已完成：
- 6 个页面，布局与视觉对齐 BrewUI：Installed / Upgrades / Discover / Services / Doctor / Configuration
- BrewUI 设计系统 1:1 移植：品牌琥珀色 `#E8971C`、语义状态色、8pt 间距网格、字体层级
- 三栏布局：侧边栏 220pt + 包列表 + 详情面板，底部可折叠 Console
- **native 桥（libcellar_bridge.so）**：移植自 Harbor，spawn/pidfile/kill
- **实时数据**：HAP 内执行 `brew info --installed --json=v2`，加载 280 个已安装包（真机验证）
- Cellar 品牌：琥珀色酒桶图标，bundle id `com.social4hyq.cellar`

### 关键技术点（HAP 内跑 brew 的坑）
1. 必须用 `~/.harmonybrew/bin/brew` **symlink** 调用——直接调 `Homebrew/bin/brew` 会导致 prefix/cellar 推导错误、返回空结果
2. `zsh --no-rcs --no-global-rcs -c 'cd <home> && exec brew …'`——避开 `~/.zshenv` 噪声 + brew 的 cwd 可读性检查
3. 干净 env 注入 HOME/PATH/TMPDIR/HOMEBREW_TEMP，关闭 auto-update/color/analytics
4. 输出重定向到沙箱日志，UI 异步轮询 pidfile + 读回解析

全部 6 页已接实时数据：
- ✅ Installed / Upgrades / Discover（brew info --installed --json=v2，280 formulae）
- ✅ Doctor（brew doctor --json，6 findings）
- ✅ Configuration（brew config，31 items）
- ✅ Services（**Harbor 回环 IPC**，读 Harbor HAP 托管的真实服务状态；Harmonybrew 的 `brew services` 在鸿蒙无实现，故改走 Harbor）

写命令（install/uninstall/upgrade）：
- ✅ 通过 native 桥执行，shell 包装捕获退出码（`.exit` 文件），stdin 接 /dev/null 避免交互卡死
- ✅ 取消用 `killGroup(pgid, sig)` 杀整个进程组（brew 的 curl/git 子进程一并回收）
- ✅ 完成后自动刷新包数据，Console 实时 tail 日志

未实现（后续阶段）：
- Console 富文本渲染（当前纯文本 tail）/ streaming push（当前轮询）
- Discover 未接远端 formulae.brew.sh API（用本地 4664 formula 目录）

## 构建与安装

需要 debug profile（`CUSTOM_SANDBOX` + `READ_WRITE_USER_FILE` ACL）：

```sh
bash build-all.sh
```

- 签名工程：`~/.app-installer/projects/com.social4hyq.cellar`
- HAP 产物：`dist/cellar-signed.hap`

## 数据文件

`entry/src/main/ets/data/PackagesData.ets` 由 `brew info --installed --json=v2` 导出精简生成：
```sh
brew info --installed --json=v2 > /tmp/all.json
# 用脚本提取 name/desc/version/license/tap/deps/outdated/installTime 等字段
```

## 后续路线

见 `~/HarmonyPC/Workspace/openspec/specs/brewui-ohos-feasibility.md` 的完整可行性分析：

- **P0（本阶段）** 只读仪表盘 ✅
- **P1** 长任务执行层（native job helper：退出码回写 / 进程组取消 / stdout 回流）
- **P2** 发现页接本地 4664 formula 目录
- **P3** Console 富文本、Doctor 实时诊断

## 合规

界面设计参考 BrewUI（AGPL-3.0），但本项目为独立 ArkTS 重写，仅借鉴功能划分与设计 token，未复制其 Swift 源码，无 AGPL 衍生义务。brew 命令输出作为数据处理。

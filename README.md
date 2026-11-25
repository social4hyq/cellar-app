# Cellar — Homebrew GUI for HarmonyOS

基于 [BrewUI](https://github.com/Homebrew/BrewUI) 界面设计的鸿蒙原生包管理 GUI。纯 ArkTS 实现，界面 1:1 复刻 BrewUI 的设计系统。

> 名称来源：Homebrew 的安装目录就叫 Cellar（酒窖）。

## 当前阶段：Phase 1 — UI 复刻（静态数据）

已完成：
- 6 个页面，布局与视觉对齐 BrewUI：Installed / Upgrades / Discover / Services / Doctor / Configuration
- BrewUI 设计系统 1:1 移植：品牌琥珀色 `#E8971C`、语义状态色、8pt 间距网格、字体层级（来自 `BrewColors.swift` / `BrewSpacing.swift` / `BrewFonts.swift`）
- 三栏布局：侧边栏 220pt + 包列表 + 详情面板，底部可折叠 Console
- 真实静态数据：313 个已安装 formula，由 `brew info --installed --json=v2` 导出（含 desc/version/license/tap/deps/outdated）
- Cellar 品牌：琥珀色酒桶图标，bundle id `com.social4hyq.cellar`

未实现（后续阶段）：
- brew 命令真实执行（install/uninstall/upgrade）——需 native 桥 job 生命周期层
- 服务启停控制、Doctor 实时诊断、配置页实时读取
- Console 真实 streaming 输出

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

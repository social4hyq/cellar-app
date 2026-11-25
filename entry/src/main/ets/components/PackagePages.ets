// 包相关页面：Installed（三栏）、Upgrades、Discover
import { C, L, F } from '../theme/Tokens';
import { LivePkg } from '../data/BrewRunner';

// 时间戳（秒）-> "31 Oct 2024"
function formatDate(ts: number): string {
  if (ts <= 0) return '—';
  const d = new Date(ts * 1000);
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return d.getDate() + ' ' + months[d.getMonth()] + ' ' + d.getFullYear();
}

// 类型徽章：FORMULA / CASK（本环境全 formula，保留视觉）
interface BadgeParam { p: LivePkg; }
@Builder
function TypeBadge(bp: BadgeParam) {
  Text('FORMULA')
    .fontSize(F.caption2).fontWeight(FontWeight.Bold).fontColor(C.textBrand)
    .padding({ left: 5, right: 5, top: 1, bottom: 1 })
    .borderRadius(4).backgroundColor(C.brandTint)
}

// 绿勾（已安装）
@Builder
function InstalledCheck() {
  Text('✓').fontSize(F.caption).fontColor(Color.White)
    .backgroundColor(C.statusSuccess).borderRadius(9)
    .width(16).height(16).textAlign(TextAlign.Center)
}

// 包行（列表中间栏）
@Component
struct PackageRow {
  @Prop p: LivePkg;
  @Prop selected: boolean = false;
  onSelect: (p: LivePkg) => void = () => {};

  build() {
    Row({ space: L.sm }) {
      Column({ space: 3 }) {
        Row({ space: 6 }) {
          Text(this.p.name).fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
          TypeBadge({ p: this.p })
          InstalledCheck()
        }
        Text(this.p.desc.length > 0 ? this.p.desc : 'No description')
          .fontSize(F.callout).fontColor(C.textSecondary)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text('v' + this.p.installedVersion).fontSize(F.caption2).fontColor(C.textTertiary)
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: L.md, right: L.md, top: L.sm, bottom: L.sm })
    .borderRadius(L.radiusMd)
    .backgroundColor(this.selected ? C.brandTint : Color.Transparent)
    .border({ width: { bottom: 1 }, color: C.borderSeparator })
    .onClick(() => { this.onSelect(this.p); })

  }
}

// 详情面板（右侧）
@Component
struct DetailPanel {
  @Prop p: LivePkg | undefined = undefined;
  @Prop taskPhase: string = '';
  onUninstall: (p: LivePkg) => void = () => {};

  @Builder
  MetaRow(label: string, value: string) {
    Row({ space: L.md }) {
      Text(label).fontSize(F.callout).fontColor(C.textSecondary).width(96)
      Text(value).fontSize(F.callout).fontColor(C.textPrimary).layoutWeight(1)
    }.width('100%').padding({ top: 3, bottom: 3 })
  }

  build() {
    if (this.p !== undefined) {
      Scroll() {
        Column({ space: L.md }) {
          // 头部
          Row({ space: L.md }) {
            Stack() {
              Rect().width(40).height(40).radius(L.radiusMd).fill(C.brandTint)
              Text('📦').fontSize(20)
            }.width(40).height(40)
            Column({ space: 2 }) {
              Row({ space: 6 }) {
                Text(this.p!.name).fontSize(F.title2).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
                TypeBadge({ p: this.p! })
                InstalledCheck()
              }
              Text(this.p!.desc).fontSize(F.callout).fontColor(C.textSecondary)
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          }.width('100%')

          Divider().color(C.borderSeparator)

          // Details
          Column({ space: 2 }) {
            Text('Details').fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            this.MetaRow('Installed', this.p!.installedVersion)
            this.MetaRow('Latest version', this.p!.latestVersion)
            this.MetaRow('Installed on', 'Poured from bottle — ' + formatDate(this.p!.installTime))
            this.MetaRow('Install reason', this.p!.installedOnRequest ? 'As requested' : 'As dependency')
            this.MetaRow('Licence', this.p!.license)
            this.MetaRow('Source', this.p!.tap + ' ↗')
            this.MetaRow('Homepage', this.p!.homepage + ' ↗')
          }
          .width('100%')

          Divider().color(C.borderSeparator)

          Column({ space: 4 }) {
            Text('Dependencies').fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            if (this.p!.deps.length === 0) {
              Text('No dependencies.').fontSize(F.callout).fontColor(C.textSecondary)
            } else {
              ForEach(this.p!.deps, (d: string) => {
                Text('• ' + d).fontSize(F.callout).fontColor(C.textPrimary)
              })
            }
          }.width('100%').alignItems(HorizontalAlign.Start)

          Divider().color(C.borderSeparator)

          // Uninstall（占位）
          Column({ space: L.sm }) {
            Text('Uninstall').fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            Column({ space: 0 }) {
              Row({ space: L.sm }) {
                Text('⌘').fontSize(F.caption).fontColor(C.textSecondary)
                Text('Terminal command').fontSize(F.caption).fontColor(C.textSecondary).layoutWeight(1)
                Text('Copy').fontSize(F.caption).fontColor(C.textLink)
              }.width('100%').padding({ left: L.sm, right: L.sm, top: L.sm, bottom: L.xs })
              .backgroundColor(C.surfaceRecessed)
              Text('brew uninstall --formula ' + this.p!.name)
                .fontSize(F.codeSmall).fontFamily('monospace').fontColor(C.textPrimary)
                .width('100%').padding({ left: L.sm, right: L.sm, top: L.sm, bottom: L.sm })
              Text('Uninstalls this package from this Mac')
                .fontSize(F.caption2).fontColor(C.textSecondary)
                .width('100%').padding({ left: L.sm, right: L.sm, top: 0, bottom: L.sm })
            }.width('100%').borderRadius(L.radiusMd).clip(true)
            Button(this.taskPhase === 'running' ? '卸载中…' : 'Uninstall')
              .fontSize(F.callout)
              .fontColor(this.taskPhase === 'running' ? C.textTertiary : Color.White)
              .backgroundColor(this.taskPhase === 'running' ? C.surfaceRecessed : C.statusError)
              .padding({ left: L.lg, right: L.lg, top: L.xs, bottom: L.xs })
              .borderRadius(L.radiusSm)
              .enabled(this.taskPhase !== 'running')
              .onClick(() => { if (this.p) this.onUninstall(this.p); })
          }.width('100%').alignItems(HorizontalAlign.Start)
        }
        .width('100%').padding(L.lg)
      }
      .width('100%').height('100%')
      .backgroundColor(C.surfaceElevated)
      .border({ width: { left: 1 }, color: C.borderSeparator })
    } else {
      Column() {
        Text('Select a package to see its details').fontSize(F.callout).fontColor(C.textTertiary)
      }.width('100%').height('100%').justifyContent(FlexAlign.Center)
       .backgroundColor(C.surfaceElevated)
       .border({ width: { left: 1 }, color: C.borderSeparator })
    }
  }
}

// ============ Installed 页（三栏）============
@Component
export struct InstalledPage {
  @Prop packages: LivePkg[] = [];
  @Prop taskPhase: string = '';
  onUninstall: (p: LivePkg) => void = () => {};
  @State selected: LivePkg | undefined = undefined;
  @State query: string = '';
  @State scope: string = 'All';
  @State hideDeps: boolean = false;

  private filtered(): LivePkg[] {
    let list = this.packages.slice();
    if (this.scope === 'Formulae') list = list.filter((p: LivePkg): boolean => !p.fullName.includes('cask'));
    if (this.scope === 'Casks') list = list.filter((p: LivePkg): boolean => p.fullName.includes('cask'));
    if (this.query.length > 0) {
      const q = this.query.toLowerCase();
      list = list.filter((p: LivePkg): boolean => p.name.toLowerCase().includes(q) || p.desc.toLowerCase().includes(q));
    }
    if (this.hideDeps) list = list.filter((p: LivePkg): boolean => p.installedOnRequest);
    return list;
  }

  build() {
    Column({ space: 0 }) {
      // 顶部 header
      Column({ space: 4 }) {
        Row() {
          Column() {
            Text('Installed').fontSize(F.title3).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            Text('Browse or search your installed packages').fontSize(F.caption).fontColor(C.textSecondary)
          }.alignItems(HorizontalAlign.Start)
          Blank()
          Row({ space: 6 }) {
            Text('🔍').fontSize(12).fontColor(C.textSecondary)
            TextInput({ placeholder: 'Search Installed Packages', text: this.query })
              .fontSize(F.callout).fontColor(C.textPrimary).placeholderColor(C.textTertiary)
              .backgroundColor(Color.Transparent).borderWidth(0)
              .width(200).height(28)
              .onChange((v: string) => { this.query = v; })
          }
          .padding({ left: L.sm, right: L.md, top: 4, bottom: 4 })
          .borderRadius(16).backgroundColor(C.surfaceElevated)
          .border({ width: 1, color: C.borderDefault })
        }.width('100%')

        Row() {
          Column() {
            Text('Your packages').fontSize(F.title1).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            Text(this.packages.length + ' packages').fontSize(F.callout).fontColor(C.textSecondary)
          }.alignItems(HorizontalAlign.Start)

          Blank()

          // All / Formulae / Casks 分段控件
          Row({ space: 0 }) {
            ForEach(['All', 'Formulae', 'Casks'], (s: string) => {
              Text(s).fontSize(F.callout).fontWeight(this.scope === s ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.scope === s ? Color.White : C.textSecondary)
                .padding({ left: 12, right: 12, top: 5, bottom: 5 })
                .borderRadius(6)
                .backgroundColor(this.scope === s ? C.brandPrimary : Color.Transparent)
                .onClick(() => { this.scope = s; })
            })
          }.backgroundColor(C.surfaceRecessed).borderRadius(8).padding(2)
        }.width('100%').margin({ top: L.md })

        Row({ space: L.sm }) {
          Text('Hide dependencies').fontSize(F.callout).fontColor(C.textSecondary)
          Toggle({ type: ToggleType.Switch, isOn: this.hideDeps }).width(36).height(20)
            .onChange((v: boolean) => { this.hideDeps = v; })
        }.margin({ top: L.sm })
      }
      .width('100%').padding({ left: L.lg, right: L.lg, top: L.md, bottom: L.md })
      .backgroundColor(C.surface)
      .border({ width: { bottom: 1 }, color: C.borderSeparator })

      // 三栏内容：列表 + 详情
      Row({ space: 0 }) {
        Scroll() {
          Column({ space: 2 }) {
            ForEach(this.filtered(), (p: LivePkg) => {
              PackageRow({ p: p, selected: this.selected?.name === p.name, onSelect: (x: LivePkg) => { this.selected = x; } })
            })
          }.width('100%').padding({ left: L.sm, right: L.sm, top: L.sm, bottom: L.sm })
        }
        .layoutWeight(1).height('100%')
        .backgroundColor(C.surface)

        DetailPanel({ p: this.selected, taskPhase: this.taskPhase, onUninstall: this.onUninstall })
          .width(L.inspectorWidth + 80)
      }
      .width('100%').layoutWeight(1)
    }
    .width('100%').height('100%')
    .backgroundColor(C.surfaceElevated)
  }
}

// ============ Upgrades 页 ============
@Component
export struct UpgradesPage {
  @Prop packages: LivePkg[] = [];
  @Prop taskPhase: string = '';
  onUpgrade: (p: LivePkg) => void = () => {};
  onUpgradeAll: () => void = () => {};
  onCancel: () => void = () => {};
  @State selected: LivePkg | undefined = undefined;
  private outdated(): LivePkg[] { return this.packages.filter((p: LivePkg): boolean => p.outdated); }

  build() {
    Column({ space: 0 }) {
      Column({ space: 4 }) {
        Text('Upgrades').fontSize(F.title3).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
        Text('Packages with newer versions available').fontSize(F.caption).fontColor(C.textSecondary)
      }.width('100%').padding({ left: L.lg, right: L.lg, top: L.md, bottom: L.md })
       .backgroundColor(C.surface).border({ width: { bottom: 1 }, color: C.borderSeparator })

      Row({ space: 0 }) {
        Scroll() {
          Column({ space: L.sm }) {
            Row({ space: 6 }) {
              Text('⬆').fontSize(14).fontColor(C.brandPrimary)
              Text(this.outdated().length + ' outdated packages').fontSize(F.title2).fontWeight(FontWeight.Bold).fontColor(C.textPrimary).layoutWeight(1)
              if (this.taskPhase === 'running') {
                Button('取消').fontSize(F.caption).fontColor(C.statusError).backgroundColor(C.statusErrorSubtle)
                  .height(26).onClick(() => { this.onCancel(); })
              } else if (this.outdated().length > 0) {
                Button('Upgrade All').fontSize(F.caption).fontColor(Color.White).backgroundColor(C.brandPrimary)
                  .height(26).onClick(() => { this.onUpgradeAll(); })
              }
            }.width('100%').padding({ left: L.lg, right: L.lg, top: L.md })
            ForEach(this.outdated(), (p: LivePkg) => {
              Row({ space: L.sm }) {
                Column({ space: 2 }) {
                  Text(p.name).fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
                  Text(p.desc).fontSize(F.callout).fontColor(C.textSecondary).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Text(p.installedVersion + ' → ' + p.latestVersion).fontSize(F.caption).fontColor(C.brandPrimary)
                TypeBadge({ p: p })
                Button('Upgrade').fontSize(F.caption2).fontColor(Color.White).backgroundColor(C.brandPrimary)
                  .height(24).padding({ left: 8, right: 8 })
                  .enabled(this.taskPhase !== 'running')
                  .onClick(() => { this.onUpgrade(p); })
              }.width('100%').padding({ left: L.md, right: L.md, top: L.sm, bottom: L.sm })
               .borderRadius(L.radiusMd).backgroundColor(this.selected?.name === p.name ? C.brandTint : Color.Transparent)
               .onClick(() => { this.selected = p; })
            })
          }.width('100%').padding({ bottom: L.sm })
        }.layoutWeight(1).height('100%').backgroundColor(C.surface)
        DetailPanel({ p: this.selected }).width(L.inspectorWidth + 80)
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor(C.surfaceElevated)
  }
}

// ============ Discover 页（占位 + 本地数据）============
@Component
export struct DiscoverPage {
  @Prop packages: LivePkg[] = [];
  @State query: string = '';
  @State selected: LivePkg | undefined = undefined;
  private suggestions(): LivePkg[] {
    // 模拟"目录"：取包名含查询词的前 60 个（第一阶段静态数据）
    let list = this.packages.slice();
    if (this.query.length > 0) {
      const q = this.query.toLowerCase();
      list = list.filter((p: LivePkg): boolean => p.name.toLowerCase().includes(q));
    }
    return list.slice(0, 60);
  }
  build() {
    Column({ space: 0 }) {
      Column({ space: 4 }) {
        Text('Discover').fontSize(F.title3).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
        Text('Browse packages available for Homebrew').fontSize(F.caption).fontColor(C.textSecondary)
        Row({ space: 6 }) {
          Text('🔍').fontSize(12).fontColor(C.textSecondary)
          TextInput({ placeholder: 'Search Formulae', text: this.query })
            .fontSize(F.callout).backgroundColor(Color.Transparent).borderWidth(0)
            .width(260).height(28).onChange((v: string) => { this.query = v; })
        }.padding({ left: L.sm, right: L.md, top: 4, bottom: 4 })
         .borderRadius(16).backgroundColor(C.surfaceElevated)
         .border({ width: 1, color: C.borderDefault }).margin({ top: L.sm })
      }.width('100%').padding({ left: L.lg, right: L.lg, top: L.md, bottom: L.md })
       .backgroundColor(C.surface).border({ width: { bottom: 1 }, color: C.borderSeparator })
      Row({ space: 0 }) {
        Scroll() {
          Column({ space: 2 }) {
            Text(this.query.length > 0 ? (this.suggestions().length + ' results') : 'Popular / all formulae (local catalogue)')
              .fontSize(F.caption).fontColor(C.textTertiary).padding({ left: L.md, top: L.sm })
            ForEach(this.suggestions(), (p: LivePkg) => {
              Row({ space: L.sm }) {
                Text(p.name).fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
                TypeBadge({ p: p })
                InstalledCheck()
                Blank()
                Text(p.desc).fontSize(F.caption).fontColor(C.textSecondary).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(2)
              }.width('100%').padding({ left: L.md, right: L.md, top: 6, bottom: 6 })
               .borderRadius(L.radiusMd).backgroundColor(this.selected?.name === p.name ? C.brandTint : Color.Transparent)
               .onClick(() => { this.selected = p; })
            })
          }.width('100%').padding({ bottom: L.sm })
        }.layoutWeight(1).height('100%').backgroundColor(C.surface)
        DetailPanel({ p: this.selected }).width(L.inspectorWidth + 80)
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor(C.surfaceElevated)
  }
}

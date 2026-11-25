// 其余页面：Services / Doctor / Configuration（第一阶段占位 + 静态数据）
import { C, L, F } from '../theme/Tokens';

// ============ Services 页 ============
interface SvcItem { name: string; status: string; running: boolean; user: string; }
const SERVICES: SvcItem[] = [
  { name: 'social4hyq/core/mihomo', status: 'started', running: true, user: 'currentUser' },
  { name: 'social4hyq/core/sshd', status: 'stopped', running: false, user: 'currentUser' },
  { name: 'social4hyq/core/herdr', status: 'stopped', running: false, user: 'currentUser' },
];

@Component
export struct ServicesPage {
  @State selected: SvcItem | undefined = SERVICES[0];
  build() {
    Column({ space: 0 }) {
      Column({ space: 4 }) {
        Text('Services').fontSize(F.title3).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
        Text('Homebrew services on this Mac').fontSize(F.caption).fontColor(C.textSecondary)
      }.width('100%').padding({ left: L.lg, right: L.lg, top: L.md, bottom: L.md })
       .backgroundColor(C.surface).border({ width: { bottom: 1 }, color: C.borderSeparator })
      Row({ space: 0 }) {
        Scroll() {
          Column({ space: 2 }) {
            ForEach(SERVICES, (s: SvcItem) => {
              Row({ space: L.sm }) {
                Circle({ width: 8, height: 8 }).fill(s.running ? C.statusSuccess : C.textTertiary)
                Column({ space: 2 }) {
                  Text(s.name).fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
                  Text(s.status).fontSize(F.caption).fontColor(C.textSecondary)
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
              }.width('100%').padding({ left: L.md, right: L.md, top: L.sm, bottom: L.sm })
               .borderRadius(L.radiusMd).backgroundColor(this.selected?.name === s.name ? C.brandTint : Color.Transparent)
               .onClick(() => { this.selected = s; })
            })
          }.width('100%').padding(L.sm)
        }.layoutWeight(1).height('100%').backgroundColor(C.surface)
        Column({ space: L.md }) {
          if (this.selected !== undefined) {
            Text(this.selected!.name).fontSize(F.title2).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            Text('Status: ' + this.selected!.status).fontSize(F.callout).fontColor(C.textSecondary)
            Text('User: ' + this.selected!.user).fontSize(F.callout).fontColor(C.textSecondary)
            Divider().color(C.borderSeparator)
            Text('Service control will be available when the native bridge is connected.')
              .fontSize(F.callout).fontColor(C.textTertiary)
          }
        }.width(L.inspectorWidth + 80).height('100%').padding(L.lg)
         .backgroundColor(C.surfaceElevated).border({ width: { left: 1 }, color: C.borderSeparator })
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor(C.surfaceElevated)
  }
}

// ============ Doctor 页 ============
interface Finding { tier: string; title: string; detail: string; }
const FINDINGS: Finding[] = [
  { tier: 'warning', title: 'Warning: broken symlinks', detail: 'Some formulae have broken symlinks in the Cellar.' },
  { tier: 'info', title: 'Info: auto-update', detail: 'Homebrew auto-update is enabled.' },
  { tier: 'success', title: 'No specific problems detected', detail: 'Your Homebrew installation looks healthy.' },
];

@Component
export struct DoctorPage {
  build() {
    Column({ space: 0 }) {
      Column({ space: 4 }) {
        Text('Doctor').fontSize(F.title3).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
        Text('Check your Homebrew installation for problems').fontSize(F.caption).fontColor(C.textSecondary)
      }.width('100%').padding({ left: L.lg, right: L.lg, top: L.md, bottom: L.md })
       .backgroundColor(C.surface).border({ width: { bottom: 1 }, color: C.borderSeparator })
      Scroll() {
        Column({ space: L.sm }) {
          ForEach(FINDINGS, (f: Finding) => {
            Row({ space: L.sm }) {
              Text(f.tier === 'success' ? '✓' : (f.tier === 'warning' ? '⚠' : 'ⓘ'))
                .fontSize(16).fontColor(f.tier === 'success' ? C.statusSuccess : (f.tier === 'warning' ? C.statusWarning : C.statusInfo))
              Column({ space: 3 }) {
                Text(f.title).fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
                Text(f.detail).fontSize(F.callout).fontColor(C.textSecondary)
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }.width('100%').padding(L.md).borderRadius(L.radiusMd).backgroundColor(C.surface)
          })
          Row({ space: L.sm }) {
            Text('ⓘ').fontSize(12).fontColor(C.textTertiary)
            Text('Full diagnostics require running brew doctor (native bridge integration pending).')
              .fontSize(F.caption).fontColor(C.textTertiary)
          }.padding(L.md)
        }.width('100%').padding({ left: L.xl, right: L.xl, top: L.lg, bottom: L.lg })
      }.layoutWeight(1).height('100%').backgroundColor(C.surfaceElevated)
    }.width('100%').height('100%').backgroundColor(C.surfaceElevated)
  }
}

// ============ Configuration 页 ============
interface ConfigItem { key: string; value: string; }
const CONFIG: ConfigItem[] = [
  { key: 'HOMEBREW_VERSION', value: '7.0.9_7' },
  { key: 'ORIGIN', value: 'https://atomgit.com/Harmonybrew/brew.git' },
  { key: 'Branch', value: 'main' },
  { key: 'HOMEBREW_PREFIX', value: '/storage/Users/currentUser/.harmonybrew' },
  { key: 'HOMEBREW_CELLAR', value: '/storage/Users/currentUser/.harmonybrew/Cellar' },
  { key: 'Ruby', value: '4.0.10' },
  { key: 'OS', value: 'HarmonyOS (aarch64-linux-ohos)' },
  { key: 'Core tap', value: 'harmonybrew/homebrew-core' },
];

@Component
export struct ConfigurationPage {
  build() {
    Column({ space: 0 }) {
      Column({ space: 4 }) {
        Text('Configuration').fontSize(F.title3).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
        Text('Homebrew environment and settings').fontSize(F.caption).fontColor(C.textSecondary)
      }.width('100%').padding({ left: L.lg, right: L.lg, top: L.md, bottom: L.md })
       .backgroundColor(C.surface).border({ width: { bottom: 1 }, color: C.borderSeparator })
      Scroll() {
        Column({ space: L.sm }) {
          Text('brew config').fontSize(F.title2).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            .margin({ top: L.md, bottom: L.sm })
          ForEach(CONFIG, (c: ConfigItem) => {
            Row({ space: L.md }) {
              Text(c.key).fontSize(F.callout).fontColor(C.textSecondary).width(200)
              Text(c.value).fontSize(F.callout).fontColor(C.textPrimary).fontFamily('monospace').layoutWeight(1)
            }.width('100%').padding({ left: L.md, right: L.md, top: 6, bottom: 6 })
             .borderRadius(L.radiusSm).backgroundColor(C.surface)
          })
          Row({ space: L.sm }) {
            Text('ⓘ').fontSize(12).fontColor(C.textTertiary)
            Text('Configuration is read from brew.env files; live values require native bridge integration.')
              .fontSize(F.caption).fontColor(C.textTertiary)
          }.margin({ top: L.lg })
        }.width('100%').padding({ left: L.xl, right: L.xl, top: L.sm, bottom: L.lg })
      }.layoutWeight(1).height('100%').backgroundColor(C.surfaceElevated)
    }.width('100%').height('100%').backgroundColor(C.surfaceElevated)
  }
}

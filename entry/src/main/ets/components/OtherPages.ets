// 其余页面：Services / Doctor / Configuration
import { C, L, F } from '../theme/Tokens';
import { DoctorResult, DoctorFinding, ConfigItem } from '../data/BrewRunner';
import { HarborService } from '../data/HarborIpc';

// ============ Services 页（由 Harbor HAP 托管，经回环 IPC 读真实状态）============
@Component
export struct ServicesPage {
  @Prop services: HarborService[] = [];
  @Prop loaded: boolean = false;
  onRefresh: () => void = () => {};
  @State selected: HarborService | undefined = undefined;

  build() {
    Column({ space: 0 }) {
      Column({ space: 4 }) {
        Row() {
          Column() {
            Text('Services').fontSize(F.title3).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            Text('Managed by Harbor · loopback IPC').fontSize(F.caption).fontColor(C.textSecondary)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          Button('↻').fontSize(F.callout).fontColor(C.textBrand).backgroundColor(C.brandTint)
            .width(28).height(28).onClick(() => { this.onRefresh(); })
        }.width('100%')
      }.width('100%').padding({ left: L.lg, right: L.lg, top: L.md, bottom: L.md })
       .backgroundColor(C.surface).border({ width: { bottom: 1 }, color: C.borderSeparator })
      Row({ space: 0 }) {
        Scroll() {
          Column({ space: 2 }) {
            if (!this.loaded) {
              Text('连接 Harbor IPC…').fontSize(F.callout).fontColor(C.textTertiary).padding(L.md)
            } else if (this.services.length === 0) {
              Text('Harbor 未运行或无服务').fontSize(F.callout).fontColor(C.textTertiary).padding(L.md)
            } else {
              ForEach(this.services, (s: HarborService) => {
                Row({ space: L.sm }) {
                  Circle({ width: 8, height: 8 }).fill(s.status === 'started' ? C.statusSuccess : (s.status === 'disabled' ? C.textTertiary : C.statusWarning))
                  Column({ space: 2 }) {
                    Text(s.name).fontSize(F.body).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
                    Text(s.status + (s.pid > 0 ? ' · PID ' + s.pid : '')).fontSize(F.caption).fontColor(C.textSecondary)
                  }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                }.width('100%').padding({ left: L.md, right: L.md, top: L.sm, bottom: L.sm })
                 .borderRadius(L.radiusMd).backgroundColor(this.selected?.name === s.name ? C.brandTint : Color.Transparent)
                 .onClick(() => { this.selected = s; })
              })
            }
          }.width('100%').padding(L.sm)
        }.layoutWeight(1).height('100%').backgroundColor(C.surface)
        Column({ space: L.md }) {
          if (this.selected !== undefined) {
            Text(this.selected!.name).fontSize(F.title2).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
            Text('Status: ' + this.selected!.status).fontSize(F.callout).fontColor(C.textSecondary)
            Text('PID: ' + (this.selected!.pid > 0 ? this.selected!.pid.toString() : '—')).fontSize(F.callout).fontColor(C.textSecondary)
            Divider().color(C.borderSeparator)
            Text('服务由 Harbor HAP 托管。用 `harbor start/stop/restart <name>` 管理。')
              .fontSize(F.callout).fontColor(C.textTertiary)
          } else {
            Text('Select a service').fontSize(F.callout).fontColor(C.textTertiary)
          }
        }.width(L.inspectorWidth + 80).height('100%').padding(L.lg)
         .backgroundColor(C.surfaceElevated).border({ width: { left: 1 }, color: C.borderSeparator })
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor(C.surfaceElevated)
  }
}

// ============ Doctor 页（实时 brew doctor --json）============
function tierIcon(t: number): string { return t >= 2 ? '✕' : (t === 1 ? '⚠' : '✓'); }
function tierColor(t: number): string { return t >= 2 ? C.statusError : (t === 1 ? C.statusWarning : C.statusSuccess); }

@Component
export struct DoctorPage {
  @Prop result: DoctorResult = { tier: 0, findings: [] };
  @Prop loaded: boolean = false;

  build() {
    Column({ space: 0 }) {
      Column({ space: 4 }) {
        Text('Doctor').fontSize(F.title3).fontWeight(FontWeight.Bold).fontColor(C.textPrimary)
        Text('Check your Homebrew installation for problems').fontSize(F.caption).fontColor(C.textSecondary)
      }.width('100%').padding({ left: L.lg, right: L.lg, top: L.md, bottom: L.md })
       .backgroundColor(C.surface).border({ width: { bottom: 1 }, color: C.borderSeparator })
      Scroll() {
        Column({ space: L.sm }) {
          if (!this.loaded) {
            Text('Running brew doctor…').fontSize(F.callout).fontColor(C.textTertiary).padding(L.md)
          } else if (this.result.findings.length === 0) {
            Row({ space: L.sm }) {
              Text('✓').fontSize(16).fontColor(C.statusSuccess)
              Text('No specific problems detected').fontSize(F.body).fontColor(C.textPrimary)
            }.width('100%').padding(L.md).borderRadius(L.radiusMd).backgroundColor(C.surface)
          } else {
            ForEach(this.result.findings, (f: DoctorFinding) => {
              Row({ space: L.sm }) {
                Text(tierIcon(f.tier)).fontSize(16).fontColor(tierColor(f.tier))
                Column({ space: 3 }) {
                  ForEach(f.text.split('\n').filter((ln: string): boolean => ln.trim().length > 0), (ln: string) => {
                    Text(ln).fontSize(F.callout).fontColor(ln.length > 0 && ln.charAt(0) === '#' ? C.textPrimary : C.textSecondary)
                      .width('100%')
                  })
                  if (f.affects.length > 0) {
                    Text('Affects: ' + f.affects.join(', ')).fontSize(F.caption2).fontColor(C.textTertiary)
                  }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
              }.width('100%').padding(L.md).borderRadius(L.radiusMd).backgroundColor(C.surface)
            })
          }
        }.width('100%').padding({ left: L.xl, right: L.xl, top: L.lg, bottom: L.lg })
      }.layoutWeight(1).height('100%').backgroundColor(C.surfaceElevated)
    }.width('100%').height('100%').backgroundColor(C.surfaceElevated)
  }
}

// ============ Configuration 页（实时 brew config）============
@Component
export struct ConfigurationPage {
  @Prop config: ConfigItem[] = [];
  @Prop loaded: boolean = false;

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
          if (!this.loaded) {
            Text('Reading brew config…').fontSize(F.callout).fontColor(C.textTertiary)
          } else {
            ForEach(this.config, (c: ConfigItem) => {
              Row({ space: L.md }) {
                Text(c.key).fontSize(F.callout).fontColor(C.textSecondary).width(200)
                Text(c.value).fontSize(F.callout).fontColor(C.textPrimary).fontFamily('monospace').layoutWeight(1)
              }.width('100%').padding({ left: L.md, right: L.md, top: 6, bottom: 6 })
               .borderRadius(L.radiusSm).backgroundColor(C.surface)
            })
          }
        }.width('100%').padding({ left: L.xl, right: L.xl, top: L.sm, bottom: L.lg })
      }.layoutWeight(1).height('100%').backgroundColor(C.surfaceElevated)
    }.width('100%').height('100%').backgroundColor(C.surfaceElevated)
  }
}

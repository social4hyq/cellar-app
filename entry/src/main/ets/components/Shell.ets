// 主窗口壳：侧边栏 + 功能页 + 底部 Console（对齐 BrewUI MainWindowView 三栏布局）
import { C, L, F } from '../theme/Tokens';

export enum Page {
  Installed,
  Upgrades,
  Discover,
  Services,
  Doctor,
  Configuration
}

export interface NavItem {
  page: Page;
  title: string;
  icon: string;   // 用系统符号名对应的中文/emoji 近似（ArkTS 无 SF Symbols）
}

export const NAV_ITEMS: NavItem[] = [
  { page: Page.Installed, title: 'Installed', icon: '📦' },
  { page: Page.Upgrades, title: 'Upgrades', icon: '⬆' },
  { page: Page.Discover, title: 'Discover', icon: '🔍' },
  { page: Page.Services, title: 'Services', icon: '🖥' },
  { page: Page.Doctor, title: 'Doctor', icon: '🩺' },
  { page: Page.Configuration, title: 'Configuration', icon: '⚙' },
];

// 侧边栏：220pt，选中项 brandTint 背景 + 琥珀色文字
@Component
export struct Sidebar {
  @Link current: Page;
  @Prop upgradeCount: number = 0;

  build() {
    Column() {
      // 顶部红黄绿窗控 + 侧栏切换（视觉近似 macOS）
      Row({ space: 8 }) {
        Circle({ width: 12, height: 12 }).fill('#FF5F57')
        Circle({ width: 12, height: 12 }).fill('#FEBC2E')
        Circle({ width: 12, height: 12 }).fill('#28C840')
        Blank()
        Text('▣').fontSize(16).fontColor(C.textSecondary)
      }
      .width('100%').padding({ left: L.md, right: L.md, top: L.lg, bottom: L.lg })

      // 导航项
      ForEach(NAV_ITEMS, (item: NavItem) => {
        Row({ space: L.sm }) {
          Text(item.icon).fontSize(15).width(L.iconWidth).textAlign(TextAlign.Center)
            .fontColor(this.current === item.page ? C.textBrand : C.textSecondary)
          Text(item.title).fontSize(F.body).fontWeight(FontWeight.Medium)
            .fontColor(this.current === item.page ? C.textBrand : C.textPrimary)
          Blank()
          if (item.page === Page.Upgrades && this.upgradeCount > 0) {
            Text(this.upgradeCount.toString())
              .fontSize(F.caption2).fontColor(C.textOnBrand)
              .backgroundColor(C.brandPrimary).borderRadius(9)
              .padding({ left: 6, right: 6, top: 1, bottom: 1 })
          }
        }
        .width('100%')
        .padding({ left: L.sm, right: L.md, top: L.sm, bottom: L.sm })
        .borderRadius(L.radiusMd)
        .backgroundColor(this.current === item.page ? C.brandTint : Color.Transparent)
        .margin({ bottom: L.xs })
        .onClick(() => { this.current = item.page; })

      })

      Blank()
    }
    .width(L.sidebarWidth)
    .height('100%')
    .padding({ left: L.sm, right: L.sm })
    .backgroundColor(C.surface)
    .border({ width: { right: 1 }, color: C.borderSeparator })
  }
}

// 底部 Console 折叠面板
@Component
export struct ConsolePanel {
  @State expanded: boolean = false;
  @Link consoleText: string;

  build() {
    Column() {
      // 标题条
      Row({ space: L.sm }) {
        Text('⌄').fontSize(12).fontColor(C.textSecondary)
          .rotate({ angle: this.expanded ? 180 : 0 })
          .onClick(() => { this.expanded = !this.expanded; })
        Text('Console').fontSize(F.callout).fontWeight(FontWeight.Medium).fontColor(C.textPrimary)
        Blank()
        Text('brew').fontSize(F.caption2).fontColor(C.textTertiary)
      }
      .width('100%').padding({ left: L.md, right: L.md, top: L.sm, bottom: L.sm })
      .backgroundColor(C.surfaceRecessed)
      .onClick(() => { this.expanded = !this.expanded; })

      if (this.expanded) {
        Scroll() {
          Column() {
            Text(this.consoleText)
              .fontSize(F.code).fontFamily('monospace')
              .fontColor(C.codeDefault)
              .textAlign(TextAlign.Start)
          }
          .padding(L.md)
          .width('100%')
        }
        .height(180)
        .backgroundColor(C.terminal)
      }
    }
    .width('100%')
    .backgroundColor(C.surface)
    .border({ width: { top: 1 }, color: C.borderSeparator })
  }
}

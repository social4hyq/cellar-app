import { C } from '../theme/Tokens';
import { Sidebar, ConsolePanel, Page } from '../components/Shell';
import { InstalledPage, UpgradesPage, DiscoverPage } from '../components/PackagePages';
import { ServicesPage, DoctorPage, ConfigurationPage } from '../components/OtherPages';
import { start, isRunning, output, parseInfoJson, LivePkg } from '../data/BrewRunner';

@Entry
@Component
struct Index {
  @State current: Page = Page.Installed;
  @State packages: LivePkg[] = [];
  @State loaded: boolean = false;
  @State consoleText: string = '$ brew info --installed --json=v2\n→ 正在读取…';

  aboutToAppear(): void {
    // P1：在 HAP 内执行 brew info --installed --json=v2，读回并解析成实时包列表
    start(['info', '--installed', '--json=v2'], 'info-all');
    const timer = setInterval(() => {
      if (isRunning('info-all')) return;
      clearInterval(timer);
      const out = output('info-all');
      const pkgs = parseInfoJson(out);
      if (pkgs.length > 0) {
        this.packages = pkgs;
        this.loaded = true;
      }
      this.consoleText = '$ brew info --installed --json=v2\n→ ' + pkgs.length + ' formulae loaded';
    }, 500);
  }

  private upgradeCount(): number {
    let n = 0;
    for (const p of this.packages) if (p.outdated) n++;
    return n;
  }

  build() {
    Column({ space: 0 }) {
      Row({ space: 0 }) {
        Sidebar({ current: this.current, upgradeCount: this.upgradeCount() })

        Column({ space: 0 }) {
          Column() {
            if (this.current === Page.Installed) {
              InstalledPage({ packages: this.packages })
            } else if (this.current === Page.Upgrades) {
              UpgradesPage({ packages: this.packages })
            } else if (this.current === Page.Discover) {
              DiscoverPage({ packages: this.packages })
            } else if (this.current === Page.Services) {
              ServicesPage()
            } else if (this.current === Page.Doctor) {
              DoctorPage()
            } else if (this.current === Page.Configuration) {
              ConfigurationPage()
            }
          }
          .width('100%').layoutWeight(1)

          ConsolePanel({ consoleText: this.consoleText })
        }
        .layoutWeight(1).height('100%')
      }
      .width('100%').height('100%')
    }
    .width('100%').height('100%')
    .backgroundColor(C.windowBase)
  }
}

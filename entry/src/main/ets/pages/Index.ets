import { C } from '../theme/Tokens';
import { Sidebar, ConsolePanel, Page, NavItem, NAV_ITEMS } from '../components/Shell';
import { InstalledPage, UpgradesPage, DiscoverPage } from '../components/PackagePages';
import { ServicesPage, DoctorPage, ConfigurationPage } from '../components/OtherPages';
import { PACKAGES } from '../data/PackagesData';

@Entry
@Component
struct Index {
  @State current: Page = Page.Installed;
  @State consoleText: string =
    '$ brew --version\n' +
    'Homebrew 7.0.9_7\n' +
    '$ brew info --installed --json=v2\n' +
    '→ 313 formulae, 0 casks\n' +
    '$ brew list --versions\n' +
    '→ abseil 20260817.0_1, acl 2.4.0, ...\n' +
    '$ brew outdated\n' +
    '→ social4hyq/core/postman-app\n' +
    '→ social4hyq/core/vite-plus\n';

  private upgradeCount(): number {
    let n = 0;
    for (const p of PACKAGES) if (p.outdated) n++;
    return n;
  }

  build() {
    Column({ space: 0 }) {
      Row({ space: 0 }) {
        Sidebar({ current: this.current, upgradeCount: this.upgradeCount() })

        Column({ space: 0 }) {
          // 功能页区域
          Column() {
            if (this.current === Page.Installed) {
              InstalledPage()
            } else if (this.current === Page.Upgrades) {
              UpgradesPage()
            } else if (this.current === Page.Discover) {
              DiscoverPage()
            } else if (this.current === Page.Services) {
              ServicesPage()
            } else if (this.current === Page.Doctor) {
              DoctorPage()
            } else if (this.current === Page.Configuration) {
              ConfigurationPage()
            }
          }
          .width('100%').layoutWeight(1)

          // 底部 Console
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

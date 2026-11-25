import { C } from '../theme/Tokens';
import { Sidebar, ConsolePanel, Page } from '../components/Shell';
import { InstalledPage, UpgradesPage, DiscoverPage } from '../components/PackagePages';
import { ServicesPage, DoctorPage, ConfigurationPage } from '../components/OtherPages';
import {
  start, isRunning, output, parseInfoJson, parseDoctorJson, parseConfig,
  LivePkg, DoctorResult, ConfigItem,
} from '../data/BrewRunner';
import hilog from '@ohos.hilog';

@Entry
@Component
struct Index {
  @State current: Page = Page.Installed;
  @State packages: LivePkg[] = [];
  @State loaded: boolean = false;
  @State doctor: DoctorResult = { tier: 0, findings: [] };
  @State doctorLoaded: boolean = false;
  @State config: ConfigItem[] = [];
  @State configLoaded: boolean = false;
  @State consoleText: string = '$ brew …\n→ 正在读取实时数据…';

  // 启动一个 job 并轮询，完成后执行回调
  private runJob(args: string[], id: string, done: (out: string) => void): void {
    start(args, id);
    const timer = setInterval(() => {
      if (isRunning(id)) return;
      clearInterval(timer);
      done(output(id));
    }, 500);
  }

  aboutToAppear(): void {
    // 三个只读 brew 命令并行执行（HAP 内通过 native 桥）
    this.runJob(['info', '--installed', '--json=v2'], 'info-all', (out: string) => {
      const pkgs = parseInfoJson(out);
      if (pkgs.length > 0) { this.packages = pkgs; this.loaded = true; }
      this.consoleText = '$ brew info --installed --json=v2\n→ ' + pkgs.length + ' formulae loaded';
    });
    this.runJob(['doctor', '--json'], 'doctor', (out: string) => {
      const d = parseDoctorJson(out);
      hilog.info(0, 'CellarLive', 'doctor: bytes=%{public}d findings=%{public}d', out.length, d.findings.length);
      if (out.length > 0) { this.doctor = d; this.doctorLoaded = true; }
    });
    this.runJob(['config'], 'config', (out: string) => {
      const c = parseConfig(out);
      hilog.info(0, 'CellarLive', 'config: bytes=%{public}d items=%{public}d', out.length, c.length);
      if (c.length > 0) { this.config = c; this.configLoaded = true; }
    });
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
              DoctorPage({ result: this.doctor, loaded: this.doctorLoaded })
            } else if (this.current === Page.Configuration) {
              ConfigurationPage({ config: this.config, loaded: this.configLoaded })
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

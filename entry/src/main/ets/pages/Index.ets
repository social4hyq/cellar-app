import { C } from '../theme/Tokens';
import { Sidebar, ConsolePanel, Page } from '../components/Shell';
import { InstalledPage, UpgradesPage, DiscoverPage } from '../components/PackagePages';
import { ServicesPage, DoctorPage, ConfigurationPage } from '../components/OtherPages';
import {
  start, isRunning, output, exitCode, cancel, startWrite,
  parseInfoJson, parseDoctorJson, parseConfig,
  LivePkg, DoctorResult, ConfigItem,
} from '../data/BrewRunner';
import hilog from '@ohos.hilog';
import { queryServices, HarborService } from '../data/HarborIpc';

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
  @State harborServices: HarborService[] = [];
  @State harborLoaded: boolean = false;
  // 写任务状态
  @State taskPhase: string = '';   // '' 空闲 | 'running' | 'done' | 'failed' | 'cancelled'
  @State taskLabel: string = '';

  private runJob(args: string[], id: string, done: (out: string) => void): void {
    start(args, id);
    const timer = setInterval(() => {
      if (isRunning(id)) return;
      clearInterval(timer);
      done(output(id));
    }, 500);
  }

  // 刷新包 + doctor 数据（写命令完成后调用）
  private refreshData(): void {
    this.runJob(['info', '--installed', '--json=v2'], 'info-all', (out: string) => {
      const pkgs = parseInfoJson(out);
      if (pkgs.length > 0) { this.packages = pkgs; this.loaded = true; }
    });
  }

  private loadHarborServices(): void {
    queryServices().then((svcs: HarborService[]) => {
      this.harborServices = svcs;
      this.harborLoaded = true;
      hilog.info(0, 'CellarLive', 'harbor services: %{public}d', svcs.length);
    });
  }

  aboutToAppear(): void {
    this.loadHarborServices();
    this.runJob(['info', '--installed', '--json=v2'], 'info-all', (out: string) => {
      const pkgs = parseInfoJson(out);
      if (pkgs.length > 0) { this.packages = pkgs; this.loaded = true; }
      this.consoleText = '$ brew info --installed --json=v2\n→ ' + pkgs.length + ' formulae loaded';
    });
    this.runJob(['doctor', '--json'], 'doctor', (out: string) => {
      const d = parseDoctorJson(out);
      if (out.length > 0) { this.doctor = d; this.doctorLoaded = true; }
    });
    this.runJob(['config'], 'config', (out: string) => {
      const c = parseConfig(out);
      if (c.length > 0) { this.config = c; this.configLoaded = true; }
    });
  }

  // 执行写命令：install / uninstall / upgrade
  private runWrite(label: string, args: string[], jobId: string): void {
    this.taskLabel = label;
    this.taskPhase = 'running';
    this.consoleText = '$ brew ' + args.join(' ') + '\n→ 执行中…';
    startWrite(args, jobId);
    let lastLog = '';
    const timer = setInterval(() => {
      const ec = exitCode(jobId);
      // 实时 tail 日志
      const log = output(jobId);
      if (log.length > 0 && log !== lastLog) {
        lastLog = log;
        this.consoleText = '$ brew ' + args.join(' ') + '\n' + log;
      }
      if (ec < 0) return;  // 退出码文件未出现，仍在运行
      clearInterval(timer);
      if (ec === 0) {
        this.taskPhase = 'done';
        this.consoleText = '$ brew ' + args.join(' ') + '\n' + log + '\n✓ 完成 (exit 0)';
        hilog.info(0, 'CellarWrite', '%{public}s succeeded', jobId);
      } else {
        this.taskPhase = 'failed';
        this.consoleText = '$ brew ' + args.join(' ') + '\n' + log + '\n✕ 失败 (exit ' + ec + ')';
        hilog.warn(0, 'CellarWrite', '%{public}s failed exit=%{public}d', jobId, ec);
      }
      this.refreshData();  // 完成后刷新包列表
    }, 600);
  }

  private doUninstall(p: LivePkg): void {
    this.runWrite('卸载 ' + p.name, ['uninstall', '--formula', p.name], 'write-uninstall-' + p.name);
  }
  private doUpgrade(p: LivePkg): void {
    this.runWrite('升级 ' + p.name, ['upgrade', '--formula', p.name], 'write-upgrade-' + p.name);
  }
  private doUpgradeAll(): void {
    this.runWrite('升级全部', ['upgrade', '--formula'], 'write-upgrade-all');
  }
  private doCancel(): void {
    // 取消所有可能的写任务 jobId（native killGroup 对不存在的 pid 无害）
    for (const p of this.packages) {
      cancel('write-uninstall-' + p.name);
      cancel('write-upgrade-' + p.name);
    }
    cancel('write-upgrade-all');
    this.taskPhase = 'cancelled';
    this.consoleText = '$ brew …\n⏹ 已取消';
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
              InstalledPage({
                packages: this.packages,
                onUninstall: (p: LivePkg) => { this.doUninstall(p); },
                taskPhase: this.taskPhase,
              })
            } else if (this.current === Page.Upgrades) {
              UpgradesPage({
                packages: this.packages,
                onUpgrade: (p: LivePkg) => { this.doUpgrade(p); },
                onUpgradeAll: () => { this.doUpgradeAll(); },
                onCancel: () => { this.doCancel(); },
                taskPhase: this.taskPhase,
              })
            } else if (this.current === Page.Discover) {
              DiscoverPage({ packages: this.packages })
            } else if (this.current === Page.Services) {
              ServicesPage({
                services: this.harborServices,
                loaded: this.harborLoaded,
                onRefresh: () => { this.loadHarborServices(); },
              })
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

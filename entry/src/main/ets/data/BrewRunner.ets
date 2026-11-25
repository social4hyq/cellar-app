// BrewRunner：通过 native 桥执行 brew 只读命令，输出重定向到沙箱日志，再读回解析。
// 非阻塞：spawn 立即返回；UI 用 isRunning() 轮询，done() 读结果。
import cellarBridge from 'libcellar_bridge.so';
import fileIo from '@ohos.file.fs';
import hilog from '@ohos.hilog';

const TAG = 'CellarBrew';
export const CACHE = '/data/storage/el2/base/cache/cellar';
// 必须通过 symlink 调用：brew 靠自身路径推导 prefix，直接调 Homebrew/bin/brew 会算错 cellar
const BREW = '/storage/Users/currentUser/.harmonybrew/bin/brew';
const ZSH = '/usr/bin/zsh';

function brewEnv(): Record<string, string> {
  return {
    'HOME': '/storage/Users/currentUser',
    'USER': 'currentUser',
    'LOGNAME': 'currentUser',
    'SHELL': ZSH,
    'PATH': '/storage/Users/currentUser/.harmonybrew/bin:/storage/Users/currentUser/.harmonybrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin',
    'TMPDIR': '/data/storage/el2/base/cache',
    'HOMEBREW_TEMP': '/data/storage/el2/base/cache',
    'LANG': 'en_US.UTF-8',
    'TERM': 'dumb',
    'HOMEBREW_NO_AUTO_UPDATE': '1',
    'HOMEBREW_NO_COLOR': '1',
    'HOMEBREW_NO_ANALYTICS': '1',
  };
}

// 单引号包裹 shell 参数（内部单引号用 '\'' 转义）
function shellQuote(s: string): string {
  return "'" + s.replace(/'/g, "'\\''") + "'";
}

interface JobPaths { log: string; pidfile: string; }
function paths(jobId: string): JobPaths {
  const p: JobPaths = { log: CACHE + '/' + jobId + '.log', pidfile: CACHE + '/' + jobId + '.pid' };
  return p;
}

function ensureDir(): void {
  try { if (!fileIo.accessSync(CACHE)) fileIo.mkdirSync(CACHE, true); } catch (e) {}
}

// 启动命令（非阻塞，立即返回）。args: brew 参数，如 ['info','--installed','--json=v2']
export function start(args: string[], jobId: string): boolean {
  ensureDir();
  const p = paths(jobId);
  try { if (fileIo.accessSync(p.log)) fileIo.unlinkSync(p.log); } catch (e) {}
  try { if (fileIo.accessSync(p.pidfile)) fileIo.unlinkSync(p.pidfile); } catch (e) {}
  // brew wrapper 要求 cwd 对当前用户可读；HAP 的 cwd 不满足，用 `cd <home> && exec brew` 绕过。
  // 同时 --no-rcs --no-global-rcs 隔离 ~/.zshenv 噪声（对齐 BrewUI）。
  const brewCmd: string = 'cd /storage/Users/currentUser && exec ' + BREW + ' ' + args.map((a) => shellQuote(a)).join(' ');
  const fullArgs: string[] = ['--no-rcs', '--no-global-rcs', '-c', brewCmd];
  const argsJson: string = JSON.stringify(fullArgs) as string;
  const envJson: string = JSON.stringify(brewEnv()) as string;
  try {
    const r: number = cellarBridge.spawn(ZSH, argsJson, p.log, p.pidfile, envJson);
    hilog.info(0x0000, TAG, 'start %{public}s -> %{public}d', jobId, r);
    return true;
  } catch (e) {
    hilog.error(0x0000, TAG, 'start %{public}s failed', jobId);
    return false;
  }
}

// 是否仍在运行
export function isRunning(jobId: string): boolean {
  const p = paths(jobId);
  return cellarBridge.pidFromPidfile(p.pidfile) > 0;
}

// 是否已启动过（防止未 spawn 就显示停止）
export function wasStarted(jobId: string): boolean {
  return cellarBridge.pidfileExists(paths(jobId).pidfile) === 1;
}

// 读输出日志
export function output(jobId: string): string {
  const p = paths(jobId);
  try {
    if (fileIo.accessSync(p.log)) return fileIo.readTextSync(p.log);
  } catch (e) {}
  return '';
}

// ---- brew info --json=v2 解析（最小字段）----
interface InstRaw { version?: string; time?: number; poured_from_bottle?: boolean; installed_on_request?: boolean; }
interface VersionsRaw { stable?: string; }
interface FormulaRaw {
  name?: string; full_name?: string; tap?: string; desc?: string; license?: string; homepage?: string;
  outdated?: boolean; keg_only?: boolean; pinned?: boolean; caveats?: string;
  dependencies?: string[]; versions?: VersionsRaw; installed?: InstRaw[];
}
interface InfoJson { formulae?: FormulaRaw[]; casks?: FormulaRaw[]; }

export interface LivePkg {
  name: string; fullName: string; tap: string; desc: string; license: string; homepage: string;
  installedVersion: string; latestVersion: string; outdated: boolean; poured: boolean;
  installTime: number; installedOnRequest: boolean; kegOnly: boolean; pinned: boolean;
  caveats: string; deps: string[];
}

export function parseInfoJson(json: string): LivePkg[] {
  const out: LivePkg[] = [];
  if (json.length === 0) return out;
  try {
    const d = JSON.parse(json) as InfoJson;
    const list = d.formulae ?? [];
    for (const f of list) {
      const inst = (f.installed && f.installed.length > 0) ? f.installed[0] : undefined;
      out.push({
        name: f.name ?? '',
        fullName: f.full_name ?? '',
        tap: f.tap ?? '',
        desc: f.desc ?? '',
        license: f.license ?? '',
        homepage: f.homepage ?? '',
        installedVersion: inst?.version ?? '',
        latestVersion: f.versions?.stable ?? '',
        outdated: f.outdated === true,
        poured: inst?.poured_from_bottle === true,
        installTime: inst?.time ?? 0,
        installedOnRequest: inst?.installed_on_request === true,
        kegOnly: f.keg_only === true,
        pinned: f.pinned === true,
        caveats: f.caveats ?? '',
        deps: f.dependencies ?? [],
      });
    }
  } catch (e) {
    hilog.error(0x0000, TAG, 'parseInfoJson failed');
  }
  out.sort((a, b) => a.name < b.name ? -1 : (a.name > b.name ? 1 : 0));
  return out;
}

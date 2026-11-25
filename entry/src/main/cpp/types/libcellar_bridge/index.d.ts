declare const cellarBridge: {
  spawn(binPath: string, argsJson: string, logPath: string, pidfile: string, envJson?: string): number;
  pidFromPidfile(pidfile: string): number;
  killPid(pid: number, signal: number): number;
  // 杀整个进程组（pgid==leader pid，setsid 后成立），连带子进程；返回 0=成功 -1=失败
  killGroup(pgid: number, signal: number): number;
  killAndWait(pid: number, signal: number, timeoutMs: number): number;
  pidfileExists(pidfile: string): number;
  cleanupPidfiles(dir: string, keepJson: string): number;
};

export default cellarBridge;

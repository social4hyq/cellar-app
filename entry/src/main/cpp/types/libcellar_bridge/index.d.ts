declare const cellarBridge: {
  spawn(binPath: string, argsJson: string, logPath: string, pidfile: string, envJson?: string): number;
  pidFromPidfile(pidfile: string): number;
  killPid(pid: number, signal: number): number;
  killAndWait(pid: number, signal: number, timeoutMs: number): number;
  pidfileExists(pidfile: string): number;
  cleanupPidfiles(dir: string, keepJson: string): number;
};

export default cellarBridge;

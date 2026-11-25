import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';

const TAG = 'Cellar';

// 第一阶段：纯 UI 复刻，无 native 桥 / 无 IPC / 无托盘。
// 后续接入 brew 命令时，在此处初始化 native helper 与命令中心。
export default class EntryAbility extends UIAbility {
  onCreate(): void {
    hilog.info(0x0000, TAG, 'Cellar onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, TAG, 'onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(0x0000, TAG, 'loadContent ok');

      // 横屏 PC 窗口：设置合理初始尺寸
      try {
        windowStage.getMainWindow((e: BusinessError, win: window.Window) => {
          if (!e.code) {
            win.setWindowLayoutFullScreen(false).catch(() => {});
          }
        });
      } catch (e) { /* ignore */ }
    });
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, 'onDestroy');
  }
}

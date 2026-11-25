// BrewUI 设计系统 token（按 BrewColors.swift / BrewSpacing.swift 的色值 1:1 复刻）
// srgb 分量转 hex：round(v*255)

export class C {
  // Backgrounds
  static readonly windowBase: string = '#F0F5F5';    // WindowBase
  static readonly surface: string = '#FAFAF7';       // Surface
  static readonly surfaceElevated: string = '#FFFFFF'; // SurfaceElevated
  static readonly surfaceRecessed: string = '#DCE2E2'; // SurfaceRecessed
  static readonly terminal: string = '#1E1E1E';       // Terminal

  // Text
  static readonly textPrimary: string = '#1A1A18';
  static readonly textSecondary: string = '#5C5C5C';
  static readonly textTertiary: string = '#969C9C';
  static readonly textLink: string = '#5B9BD5';
  static readonly textOnBrand: string = '#1A1A1A';
  static readonly textBrand: string = '#E8971C';
  static readonly codeDefault: string = '#D4D4D4';
  static readonly codeCommand: string = '#6BC9FC';
  static readonly codeArgument: string = '#A8D8A8';
  static readonly codeOutput: string = '#C8C8C8';
  static readonly codeError: string = '#FF7A72';

  // Brand / Accent
  static readonly brandPrimary: string = '#E8971C';
  static readonly brandPrimaryHover: string = '#FCC96B';
  static readonly brandPrimaryPressed: string = '#FBB040';
  static readonly brandTint: string = '#FEF3DC';     // 选中行/包行高亮

  // Status
  static readonly statusSuccess: string = '#3CB371';
  static readonly statusSuccessSubtle: string = '#EBF7F1';
  static readonly statusWarning: string = '#F0AD4E';
  static readonly statusWarningSubtle: string = '#FEF8EC';
  static readonly statusError: string = '#D9534F';
  static readonly statusErrorSubtle: string = '#FDECEB';
  static readonly statusInfo: string = '#5B9BD5';
  static readonly statusInfoSubtle: string = '#EFF4FC';

  // Borders
  static readonly borderDefault: string = '#14141414';
  static readonly borderStrong: string = '#29292929';
  static readonly borderBrand: string = '#E8971C';
  static readonly borderSeparator: string = '#0F000000';
}

// Layout（对齐 BrewSpacing / BrewLayout，单位 vp≈pt）
export class L {
  static readonly xxs: number = 2;
  static readonly xs: number = 4;
  static readonly sm: number = 8;
  static readonly md: number = 12;
  static readonly lg: number = 16;
  static readonly xl: number = 24;
  static readonly xxl: number = 32;

  static readonly sidebarWidth: number = 220;
  static readonly iconWidth: number = 20;
  static readonly inspectorWidth: number = 320;
  static readonly radiusMd: number = 8;
  static readonly radiusSm: number = 6;
}

// 字体层级（对齐 BrewFonts）
export class F {
  static readonly largeTitle: number = 28;
  static readonly title1: number = 22;
  static readonly title2: number = 17;
  static readonly title3: number = 15;
  static readonly body: number = 13;
  static readonly bodyEmphasized: number = 13;
  static readonly callout: number = 12;
  static readonly subheadline: number = 11;
  static readonly caption: number = 11;
  static readonly caption2: number = 10;
  static readonly code: number = 12;
  static readonly codeSmall: number = 11;
}

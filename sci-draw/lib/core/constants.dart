/// 应用常量
class AppConstants {
  static const String appName = 'SciDraw';
  static const String appVersion = '1.0.0';
  
  // 默认配置
  static const int defaultDpi = 300;
  static const double defaultLineWidth = 0.75;
  
  // API 配置
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String anthropicBaseUrl = 'https://api.anthropic.com';
  static const String qwenBaseUrl = 'https://dashscope.aliyuncs.com/compatible-mode/v1';
  static const String wenxinBaseUrl = 'https://qianfan.baidubce.com/v2';
  
  // 存储键
  static const String apiConfigBox = 'api_config';
  static const String projectsBox = 'projects';
  static const String settingsBox = 'settings';
  
  // 支持的导出格式
  static const List<String> exportFormats = ['vsdx', 'svg', 'png', 'pdf'];
  
  // 绘图类型
  static const List<String> graphTypes = [
    '技术路线图',
    '实验流程图',
    '分子机制图',
    '信号通路图',
    '研究框架图',
    '实验分组图',
    '数据分析流程图',
  ];
  
  // 期刊规范
  static const List<String> journalStandards = [
    '通用SCI标准',
    'Nature规范',
    'Science规范',
    'Cell规范',
    'IEEE规范',
    '知网核心',
  ];
}

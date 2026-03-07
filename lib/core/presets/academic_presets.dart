/// 学术规范预设
class AcademicPresets {
  /// 期刊规范预设
  static final Map<String, JournalStandard> journalStandards = {
    '通用SCI标准': JournalStandard(
      name: '通用SCI标准',
      fontFamily: 'Arial',
      fontSizeTitle: 14,
      fontSizeNode: 11,
      fontSizeLabel: 9,
      mainColors: ['#000000', '#333333', '#666666'],
      lineWidth: 0.75,
      dpi: 300,
    ),
    'Nature': JournalStandard(
      name: 'Nature',
      fontFamily: 'Arial',
      fontSizeTitle: 12,
      fontSizeNode: 10,
      fontSizeLabel: 8,
      mainColors: ['#000000', '#404040', '#808080'],
      lineWidth: 0.5,
      dpi: 300,
    ),
    'Science': JournalStandard(
      name: 'Science',
      fontFamily: 'Arial',
      fontSizeTitle: 12,
      fontSizeNode: 10,
      fontSizeLabel: 8,
      mainColors: ['#000000', '#2C3E50', '#7F8C8D'],
      lineWidth: 0.5,
      dpi: 300,
    ),
    'Cell': JournalStandard(
      name: 'Cell',
      fontFamily: 'Arial',
      fontSizeTitle: 14,
      fontSizeNode: 11,
      fontSizeLabel: 9,
      mainColors: ['#000000', '#2980B9', '#E74C3C'],
      lineWidth: 0.75,
      dpi: 300,
    ),
    'IEEE': JournalStandard(
      name: 'IEEE',
      fontFamily: 'Times New Roman',
      fontSizeTitle: 12,
      fontSizeNode: 10,
      fontSizeLabel: 8,
      mainColors: ['#000000', '#333333'],
      lineWidth: 0.5,
      dpi: 300,
    ),
    '知网核心': JournalStandard(
      name: '知网核心',
      fontFamily: '宋体',
      fontSizeTitle: 14,
      fontSizeNode: 12,
      fontSizeLabel: 10,
      mainColors: ['#000000', '#333333', '#0000FF'],
      lineWidth: 1.0,
      dpi: 300,
    ),
  };
  
  /// 绘图类型预设
  static final Map<String, GraphTypePreset> graphTypePresets = {
    '技术路线图': GraphTypePreset(
      name: '技术路线图',
      description: '展示研究方法和步骤的流程图',
      defaultLayout: 'horizontal',
      nodeShapes: ['椭圆形', '矩形', '菱形'],
      lineTypes: ['实线单向箭头'],
      typicalModules: ['文献调研', '理论分析', '实验研究', '数据分析', '结论总结'],
    ),
    '实验流程图': GraphTypePreset(
      name: '实验流程图',
      description: '展示实验步骤和过程的图表',
      defaultLayout: 'vertical',
      nodeShapes: ['矩形', '圆角矩形'],
      lineTypes: ['实线单向箭头', '虚线单向箭头'],
      typicalModules: ['实验准备', '实验操作', '数据采集', '结果分析'],
    ),
    '分子机制图': GraphTypePreset(
      name: '分子机制图',
      description: '展示分子间相互作用机制的图表',
      defaultLayout: 'center',
      nodeShapes: ['椭圆形', '矩形', '箭头'],
      lineTypes: ['实线箭头', '虚线箭头', 'T型箭头', '双向箭头'],
      typicalModules: ['上游调控', '核心机制', '下游效应'],
    ),
    '信号通路图': GraphTypePreset(
      name: '信号通路图',
      description: '展示信号传导通路的图表',
      defaultLayout: 'path',
      nodeShapes: ['椭圆形', '矩形'],
      lineTypes: ['实线箭头', '虚线箭头', 'T型箭头', '双向箭头'],
      typicalModules: ['受体', '信号分子', '转录因子', '靶基因'],
    ),
    '研究框架图': GraphTypePreset(
      name: '研究框架图',
      description: '展示研究整体框架和逻辑',
      defaultLayout: 'pyramid',
      nodeShapes: ['矩形', '圆角矩形'],
      lineTypes: ['实线箭头'],
      typicalModules: ['研究背景', '研究问题', '研究方法', '预期结论'],
    ),
    '实验分组图': GraphTypePreset(
      name: '实验分组图',
      description: '展示实验分组设计的图表',
      defaultLayout: 'tree',
      nodeShapes: ['矩形'],
      lineTypes: ['实线箭头'],
      typicalModules: ['总样本', '实验组', '对照组', '亚组'],
    ),
    '数据分析流程图': GraphTypePreset(
      name: '数据分析流程图',
      description: '展示数据分析步骤的流程图',
      defaultLayout: 'vertical',
      nodeShapes: ['矩形', '菱形'],
      lineTypes: ['实线单向箭头'],
      typicalModules: ['数据清洗', '特征工程', '模型训练', '结果评估'],
    ),
  };
  
  /// 配色方案预设
  static final List<ColorSchemePreset> colorSchemes = [
    ColorSchemePreset(
      name: '经典黑白',
      colors: ['#000000', '#333333', '#666666', '#999999', '#FFFFFF'],
      suitableFor: '所有期刊',
    ),
    ColorSchemePreset(
      name: '学术蓝',
      colors: ['#1A73E8', '#4285F4', '#8AB4F8', '#FFFFFF', '#000000'],
      suitableFor: 'SCI论文',
    ),
    ColorSchemePreset(
      name: '生命科学',
      colors: ['#34A853', '#1E8E3E', '#81C995', '#FFFFFF', '#000000'],
      suitableFor: '生物、医学',
    ),
    ColorSchemePreset(
      name: '工程灰色',
      colors: ['#5F6368', '#80868B', '#BDC1C6', '#FFFFFF', '#000000'],
      suitableFor: '工程、技术',
    ),
    ColorSchemePreset(
      name: '暖色调',
      colors: ['#EA4335', '#FBBC04', '#F9AB00', '#FFFFFF', '#000000'],
      suitableFor: '强调重点',
    ),
    ColorSchemePreset(
      name: '专业紫',
      colors: ['#9334E6', '#B388FF', '#E1BEE7', '#FFFFFF', '#000000'],
      suitableFor: '创新研究',
    ),
  ];
  
  /// 线型预设
  static final Map<String, LineTypePreset> lineTypePresets = {
    '实线单向箭头': LineTypePreset(
      name: '实线单向箭头',
      description: '直接作用/正向调控/流程推进',
      style: 'solid',
      arrowType: 'arrow',
    ),
    '虚线单向箭头': LineTypePreset(
      name: '虚线单向箭头',
      description: '间接作用/潜在关联/辅助流程',
      style: 'dashed',
      arrowType: 'arrow',
    ),
    'T型实线': LineTypePreset(
      name: 'T型实线',
      description: '直接抑制/负向调控',
      style: 'solid',
      arrowType: 'T',
    ),
    'T型虚线': LineTypePreset(
      name: 'T型虚线',
      description: '间接抑制/潜在负向调控',
      style: 'dashed',
      arrowType: 'T',
    ),
    '双向箭头': LineTypePreset(
      name: '双向箭头',
      description: '相互作用/反馈调节',
      style: 'solid',
      arrowType: 'both',
    ),
  };
}

/// 期刊规范
class JournalStandard {
  final String name;
  final String fontFamily;
  final int fontSizeTitle;
  final int fontSizeNode;
  final int fontSizeLabel;
  final List<String> mainColors;
  final double lineWidth;
  final int dpi;
  
  JournalStandard({
    required this.name,
    required this.fontFamily,
    required this.fontSizeTitle,
    required this.fontSizeNode,
    required this.fontSizeLabel,
    required this.mainColors,
    required this.lineWidth,
    required this.dpi,
  });
}

/// 绘图类型预设
class GraphTypePreset {
  final String name;
  final String description;
  final String defaultLayout;
  final List<String> nodeShapes;
  final List<String> lineTypes;
  final List<String> typicalModules;
  
  GraphTypePreset({
    required this.name,
    required this.description,
    required this.defaultLayout,
    required this.nodeShapes,
    required this.lineTypes,
    required this.typicalModules,
  });
}

/// 配色方案预设
class ColorSchemePreset {
  final String name;
  final List<String> colors;
  final String suitableFor;
  
  ColorSchemePreset({
    required this.name,
    required this.colors,
    required this.suitableFor,
  });
}

/// 线型预设
class LineTypePreset {
  final String name;
  final String description;
  final String style;
  final String arrowType;
  
  LineTypePreset({
    required this.name,
    required this.description,
    required this.style,
    required this.arrowType,
  });
}

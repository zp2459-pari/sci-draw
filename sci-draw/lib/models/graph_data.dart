/// 绘图节点模型
class GraphNode {
  final String nodeId;
  final String moduleId;
  final String nodeText;
  final String nodeType;
  final String shape;
  final Map<String, double> position;
  final Map<String, double> size;
  final String color;
  
  GraphNode({
    required this.nodeId,
    required this.moduleId,
    required this.nodeText,
    required this.nodeType,
    required this.shape,
    required this.position,
    required this.size,
    required this.color,
  });
  
  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      nodeId: json['node_id'] ?? '',
      moduleId: json['module_id'] ?? '',
      nodeText: json['node_text'] ?? '',
      nodeType: json['node_type'] ?? '流程节点',
      shape: json['shape'] ?? '矩形',
      position: Map<String, double>.from(json['position'] ?? {}),
      size: Map<String, double>.from(json['size'] ?? {}),
      color: json['color'] ?? '#FFFFFF',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'node_id': nodeId,
    'module_id': moduleId,
    'node_text': nodeText,
    'node_type': nodeType,
    'shape': shape,
    'position': position,
    'size': size,
    'color': color,
  };
}

/// 绘图线条模型
class GraphLine {
  final String lineId;
  final String startNodeId;
  final String endNodeId;
  final String lineType;
  final String arrowType;
  final String lineText;
  final String color;
  
  GraphLine({
    required this.lineId,
    required this.startNodeId,
    required this.endNodeId,
    required this.lineType,
    required this.arrowType,
    required this.lineText,
    required this.color,
  });
  
  factory GraphLine.fromJson(Map<String, dynamic> json) {
    return GraphLine(
      lineId: json['line_id'] ?? '',
      startNodeId: json['start_node_id'] ?? '',
      endNodeId: json['end_node_id'] ?? '',
      lineType: json['line_type'] ?? '实线',
      arrowType: json['arrow_type'] ?? '单向箭头',
      lineText: json['line_text'] ?? '',
      color: json['color'] ?? '#000000',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'line_id': lineId,
    'start_node_id': startNodeId,
    'end_node_id': endNodeId,
    'line_type': lineType,
    'arrow_type': arrowType,
    'line_text': lineText,
    'color': color,
  };
}

/// 绘图模块模型
class GraphModule {
  final String moduleId;
  final String moduleName;
  final Map<String, double> position;
  final Map<String, double> size;
  
  GraphModule({
    required this.moduleId,
    required this.moduleName,
    required this.position,
    required this.size,
  });
  
  factory GraphModule.fromJson(Map<String, dynamic> json) {
    return GraphModule(
      moduleId: json['module_id'] ?? '',
      moduleName: json['module_name'] ?? '',
      position: Map<String, double>.from(json['position'] ?? {}),
      size: Map<String, double>.from(json['size'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'module_id': moduleId,
    'module_name': moduleName,
    'position': position,
    'size': size,
  };
}

/// 完整的绘图数据模型
class GraphData {
  final GraphInfo graphInfo;
  final StyleConfig styleConfig;
  final List<GraphNode> nodeList;
  final List<GraphLine> lineList;
  final List<GraphModule> moduleList;
  
  GraphData({
    required this.graphInfo,
    required this.styleConfig,
    required this.nodeList,
    required this.lineList,
    required this.moduleList,
  });
  
  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      graphInfo: GraphInfo.fromJson(json['graph_info'] ?? {}),
      styleConfig: StyleConfig.fromJson(json['style_config'] ?? {}),
      nodeList: (json['node_list'] as List? ?? [])
          .map((e) => GraphNode.fromJson(e))
          .toList(),
      lineList: (json['line_list'] as List? ?? [])
          .map((e) => GraphLine.fromJson(e))
          .toList(),
      moduleList: (json['module_list'] as List? ?? [])
          .map((e) => GraphModule.fromJson(e))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'graph_info': graphInfo.toJson(),
    'style_config': styleConfig.toJson(),
    'node_list': nodeList.map((e) => e.toJson()).toList(),
    'line_list': lineList.map((e) => e.toJson()).toList(),
    'module_list': moduleList.map((e) => e.toJson()).toList(),
  };
}

class GraphInfo {
  final String graphType;
  final String targetJournal;
  final int totalModules;
  final String readDirection;
  
  GraphInfo({
    required this.graphType,
    required this.targetJournal,
    required this.totalModules,
    required this.readDirection,
  });
  
  factory GraphInfo.fromJson(Map<String, dynamic> json) {
    return GraphInfo(
      graphType: json['graph_type'] ?? '',
      targetJournal: json['target_journal'] ?? '',
      totalModules: json['total_modules'] ?? 0,
      readDirection: json['read_direction'] ?? '从左到右',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'graph_type': graphType,
    'target_journal': targetJournal,
    'total_modules': totalModules,
    'read_direction': readDirection,
  };
}

class StyleConfig {
  final String fontFamily;
  final List<String> mainColor;
  final String lineWidth;
  final int dpi;
  
  StyleConfig({
    required this.fontFamily,
    required this.mainColor,
    required this.lineWidth,
    required this.dpi,
  });
  
  factory StyleConfig.fromJson(Map<String, dynamic> json) {
    return StyleConfig(
      fontFamily: json['font_family'] ?? 'Arial',
      mainColor: List<String>.from(json['main_color'] ?? ['#000000']),
      lineWidth: json['line_width'] ?? '0.75pt',
      dpi: json['dpi'] ?? 300,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'font_family': fontFamily,
    'main_color': mainColor,
    'line_width': lineWidth,
    'dpi': dpi,
  };
}

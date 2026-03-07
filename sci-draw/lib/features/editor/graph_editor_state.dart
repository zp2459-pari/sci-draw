import 'package:flutter/material.dart';
import '../../models/graph_data.dart';

/// 图表编辑器状态
class GraphEditorState extends ChangeNotifier {
  GraphData _graphData;
  String? _selectedNodeId;
  String? _selectedLineId;
  bool _isEditing = false;
  final GlobalKey repaintBoundaryKey = GlobalKey(); // 用于 PNG 导出
  
  GraphEditorState(this._graphData);
  
  GraphData get graphData => _graphData;
  String? get selectedNodeId => _selectedNodeId;
  String? get selectedLineId => _selectedLineId;
  bool get isEditing => _isEditing;
  
  GraphNode? get selectedNode {
    if (_selectedNodeId == null) return null;
    return _graphData.nodeList.where((n) => n.nodeId == _selectedNodeId).firstOrNull;
  }
  
  GraphLine? get selectedLine {
    if (_selectedLineId == null) return null;
    return _graphData.lineList.where((l) => l.lineId == _selectedLineId).firstOrNull;
  }
  
  /// 选择节点
  void selectNode(String? nodeId) {
    _selectedNodeId = nodeId;
    _selectedLineId = null;
    notifyListeners();
  }
  
  /// 选择线条
  void selectLine(String? lineId) {
    _selectedLineId = lineId;
    _selectedNodeId = null;
    notifyListeners();
  }
  
  /// 清除选择
  void clearSelection() {
    _selectedNodeId = null;
    _selectedLineId = null;
    notifyListeners();
  }
  
  /// 开始编辑
  void startEditing() {
    _isEditing = true;
    notifyListeners();
  }
  
  /// 结束编辑
  void stopEditing() {
    _isEditing = false;
    notifyListeners();
  }
  
  /// 更新节点文字
  void updateNodeText(String nodeId, String newText) {
    final index = _graphData.nodeList.indexWhere((n) => n.nodeId == nodeId);
    if (index != -1) {
      final node = _graphData.nodeList[index];
      _graphData.nodeList[index] = GraphNode(
        nodeId: node.nodeId,
        moduleId: node.moduleId,
        nodeText: newText,
        nodeType: node.nodeType,
        shape: node.shape,
        position: node.position,
        size: node.size,
        color: node.color,
      );
      notifyListeners();
    }
  }
  
  /// 更新节点位置
  void updateNodePosition(String nodeId, double x, double y) {
    final index = _graphData.nodeList.indexWhere((n) => n.nodeId == nodeId);
    if (index != -1) {
      final node = _graphData.nodeList[index];
      _graphData.nodeList[index] = GraphNode(
        nodeId: node.nodeId,
        moduleId: node.moduleId,
        nodeText: node.nodeText,
        nodeType: node.nodeType,
        shape: node.shape,
        position: {'x': x, 'y': y},
        size: node.size,
        color: node.color,
      );
      notifyListeners();
    }
  }
  
  /// 更新节点位置 (Map 格式)
  void updateNodePositionMap(String nodeId, Map<String, double> position) {
    final index = _graphData.nodeList.indexWhere((n) => n.nodeId == nodeId);
    if (index != -1) {
      final node = _graphData.nodeList[index];
      _graphData.nodeList[index] = GraphNode(
        nodeId: node.nodeId,
        moduleId: node.moduleId,
        nodeText: node.nodeText,
        nodeType: node.nodeType,
        shape: node.shape,
        position: position,
        size: node.size,
        color: node.color,
      );
      notifyListeners();
    }
  }
  
  /// 删除节点
  void deleteNode(String nodeId) {
    _graphData.nodeList.removeWhere((n) => n.nodeId == nodeId);
    // 同时删除相关的连线
    _graphData.lineList.removeWhere((l) => l.startNodeId == nodeId || l.endNodeId == nodeId);
    _selectedNodeId = null;
    notifyListeners();
  }
  
  /// 删除线条
  void deleteLine(String lineId) {
    _graphData.lineList.removeWhere((l) => l.lineId == lineId);
    _selectedLineId = null;
    notifyListeners();
  }
  
  /// 更新节点颜色
  void updateNodeColor(String nodeId, String color) {
    final index = _graphData.nodeList.indexWhere((n) => n.nodeId == nodeId);
    if (index != -1) {
      final node = _graphData.nodeList[index];
      _graphData.nodeList[index] = GraphNode(
        nodeId: node.nodeId,
        moduleId: node.moduleId,
        nodeText: node.nodeText,
        nodeType: node.nodeType,
        shape: node.shape,
        position: node.position,
        size: node.size,
        color: color,
      );
      notifyListeners();
    }
  }
  
  /// 更新线条文字
  void updateLineText(String lineId, String newText) {
    final index = _graphData.lineList.indexWhere((l) => l.lineId == lineId);
    if (index != -1) {
      final line = _graphData.lineList[index];
      _graphData.lineList[index] = GraphLine(
        lineId: line.lineId,
        startNodeId: line.startNodeId,
        endNodeId: line.endNodeId,
        lineType: line.lineType,
        arrowType: line.arrowType,
        lineText: newText,
        color: line.color,
      );
      notifyListeners();
    }
  }
  
  /// 更新线条颜色
  void updateLineColor(String lineId, String color) {
    final index = _graphData.lineList.indexWhere((l) => l.lineId == lineId);
    if (index != -1) {
      final line = _graphData.lineList[index];
      _graphData.lineList[index] = GraphLine(
        lineId: line.lineId,
        startNodeId: line.startNodeId,
        endNodeId: line.endNodeId,
        lineType: line.lineType,
        arrowType: line.arrowType,
        lineText: line.lineText,
        color: color,
      );
      notifyListeners();
    }
  }
  
  /// 更新样式配置
  void updateStyleConfig(StyleConfig newConfig) {
    _graphData = GraphData(
      graphInfo: _graphData.graphInfo,
      styleConfig: newConfig,
      nodeList: _graphData.nodeList,
      lineList: _graphData.lineList,
      moduleList: _graphData.moduleList,
    );
    notifyListeners();
  }
}

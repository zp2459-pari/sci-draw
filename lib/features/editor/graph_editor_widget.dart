import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/graph_data.dart';
import 'graph_editor_state.dart';

/// 图表编辑器小部件 - 支持拖拽移动
class GraphEditorWidget extends StatefulWidget {
  final GraphData graphData;
  final Function(GraphData)? onChanged;
  final GlobalKey? repaintBoundaryKey; // 用于 PNG 导出
  
  const GraphEditorWidget({
    super.key,
    required this.graphData,
    this.onChanged,
    this.repaintBoundaryKey,
  });
  
  @override
  State<GraphEditorWidget> createState() => _GraphEditorWidgetState();
}

class _GraphEditorWidgetState extends State<GraphEditorWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraphEditorState(widget.graphData),
      child: const _GraphEditorContent(),
    );
  }
}

class _GraphEditorContent extends StatefulWidget {
  const _GraphEditorContent();
  
  @override
  State<_GraphEditorContent> createState() => _GraphEditorContentState();
}

class _GraphEditorContentState extends State<_GraphEditorContent> {
  String? _draggingNodeId;
  Offset? _dragStartOffset;
  Offset? _nodeStartPosition;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GraphEditorState>(
      builder: (context, state, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 画布 (用于 PNG 导出)
                RepaintBoundary(
                  key: state.repaintBoundaryKey,
                  child: GestureDetector(
                    onTap: () => state.clearSelection(),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: GestureDetector(
                        onPanStart: (details) => _onPanStart(details, state, constraints),
                        onPanUpdate: (details) => _onPanUpdate(details, state, constraints),
                        onPanEnd: (details) => _onPanEnd(details, state),
                        child: CustomPaint(
                          size: const Size(800, 600),
                          painter: _EditorPainter(
                            graphData: state.graphData,
                            selectedNodeId: state.selectedNodeId,
                            selectedLineId: state.selectedLineId,
                            draggingNodeId: _draggingNodeId,
                          ),
                          child: const SizedBox(width: 800, height: 600),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 编辑面板
                if (state.selectedNodeId != null)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _NodeEditPanel(node: state.selectedNode!),
                  ),
                
                if (state.selectedLineId != null)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _LineEditPanel(line: state.selectedLine!),
                  ),
                
                // 提示
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '🖱️ 拖拽节点移动 | 点击选择 | 滚轮缩放',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _onPanStart(DragStartDetails details, GraphEditorState state, BoxConstraints constraints) {
    final localPosition = details.localPosition;
    final size = const Size(800, 600);
    
    // 检查是否点击在某个节点上
    for (final node in state.graphData.nodeList.reversed) {
      final nodeRect = Rect.fromLTWH(
        node.position['x']! * size.width,
        node.position['y']! * size.height,
        node.size['width']! * size.width,
        node.size['height']! * size.height,
      );
      
      if (nodeRect.contains(localPosition)) {
        setState(() {
          _draggingNodeId = node.nodeId;
          _dragStartOffset = localPosition;
          _nodeStartPosition = Offset(
            node.position['x']!,
            node.position['y']!,
          );
        });
        state.selectNode(node.nodeId);
        return;
      }
    }
    
    // 检查是否点击在连线上
    for (final line in state.graphData.lineList) {
      if (_isPointNearLine(localPosition, line, state.graphData, size, 10)) {
        state.selectLine(line.lineId);
        return;
      }
    }
    
    // 点击空白处取消选择
    state.clearSelection();
  }
  
  void _onPanUpdate(DragUpdateDetails details, GraphEditorState state, BoxConstraints constraints) {
    if (_draggingNodeId == null || _dragStartOffset == null || _nodeStartPosition == null) return;
    
    final size = const Size(800, 600);
    final delta = details.localPosition - _dragStartOffset!;
    
    // 计算新位置 (转换为相对坐标)
    final newX = (_nodeStartPosition!.dx + delta.dx / size.width).clamp(0.0, 1.0 - state.graphData.nodeList.firstWhere((n) => n.nodeId == _draggingNodeId).size['width']!);
    final newY = (_nodeStartPosition!.dy + delta.dy / size.height).clamp(0.0, 1.0 - state.graphData.nodeList.firstWhere((n) => n.nodeId == _draggingNodeId).size['height']!);
    
    state.updateNodePositionMap(_draggingNodeId!, {'x': newX, 'y': newY});
  }
  
  void _onPanEnd(DragEndDetails details, GraphEditorState state) {
    setState(() {
      _draggingNodeId = null;
      _dragStartOffset = null;
      _nodeStartPosition = null;
    });
    
    // 通知变化
    if (widget.onChanged != null) {
      widget.onChanged!(state.graphData);
    }
  }
  
  bool _isPointNearLine(Offset point, GraphLine line, GraphData graphData, Size size, double threshold) {
    final startNode = graphData.nodeList.where((n) => n.nodeId == line.startNodeId).firstOrNull;
    final endNode = graphData.nodeList.where((n) => n.nodeId == line.endNodeId).firstOrNull;
    
    if (startNode == null || endNode == null) return false;
    
    final x1 = (startNode.position['x']! + startNode.size['width']! / 2) * size.width;
    final y1 = (startNode.position['y']! + startNode.size['height']! / 2) * size.height;
    final x2 = (endNode.position['x']! + endNode.size['width']! / 2) * size.width;
    final y2 = (endNode.position['y']! + endNode.size['height']! / 2) * size.height;
    
    // 计算点到线段的距离
    final distance = _pointToLineDistance(point, Offset(x1, y1), Offset(x2, y2));
    return distance < threshold;
  }
  
  double _pointToLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;
    final lengthSquared = dx * dx + dy * dy;
    
    if (lengthSquared == 0) {
      return (point - lineStart).distance;
    }
    
    var t = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) / lengthSquared;
    t = t.clamp(0.0, 1.0);
    
    final projection = Offset(
      lineStart.dx + t * dx,
      lineStart.dy + t * dy,
    );
    
    return (point - projection).distance;
  }
}

class _NodeEditPanel extends StatelessWidget {
  final GraphNode node;
  
  const _NodeEditPanel({required this.node});
  
  @override
  Widget build(BuildContext context) {
    final state = context.read<GraphEditorState>();
    final textController = TextEditingController(text: node.nodeText);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('编辑节点', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // 文字编辑
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: '节点文字',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => state.updateNodeText(node.nodeId, value),
            ),
            const SizedBox(height: 12),
            
            // 颜色选择
            const Text('节点颜色'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                '#FFFFFF', '#F5F5F5', '#E3F2FD', '#E8F5E9', '#FFF3E0', '#FCE4EC',
              ].map((color) => GestureDetector(
                onTap: () => state.updateNodeColor(node.nodeId, color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _hexToColor(color),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // 位置信息
            Text(
              '位置: (${node.position['x']!.toStringAsFixed(2)}, ${node.position['y']!.toStringAsFixed(2)})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            
            const SizedBox(height: 8),
            
            // 删除按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => state.deleteNode(node.nodeId),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('删除节点', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

class _LineEditPanel extends StatelessWidget {
  final GraphLine line;
  
  const _LineEditPanel({required this.line});
  
  @override
  Widget build(BuildContext context) {
    final state = context.read<GraphEditorState>();
    final textController = TextEditingController(text: line.lineText);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('编辑线条', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // 文字编辑
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: '线条标注',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => state.updateLineText(line.lineId, value),
            ),
            const SizedBox(height: 12),
            
            // 线条类型
            Text('类型: ${line.lineType} → ${line.arrowType}'),
            
            const SizedBox(height: 8),
            
            // 删除按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => state.deleteLine(line.lineId),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('删除线条', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorPainter extends CustomPainter {
  final GraphData graphData;
  final String? selectedNodeId;
  final String? selectedLineId;
  final String? draggingNodeId;
  
  _EditorPainter({
    required this.graphData,
    this.selectedNodeId,
    this.selectedLineId,
    this.draggingNodeId,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制模块背景
    for (final module in graphData.moduleList) {
      _drawModule(canvas, size, module);
    }
    
    // 绘制连接线
    for (final line in graphData.lineList) {
      _drawLine(canvas, size, line, line.lineId == selectedLineId);
    }
    
    // 绘制节点
    for (final node in graphData.nodeList) {
      _drawNode(canvas, size, node, node.nodeId == selectedNodeId || node.nodeId == draggingNodeId);
    }
  }
  
  void _drawModule(Canvas canvas, Size size, GraphModule module) {
    final rect = Rect.fromLTWH(
      module.position['x']! * size.width,
      module.position['y']! * size.height,
      module.size['width']! * size.width,
      module.size['height']! * size.height,
    );
    
    final paint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(rect, paint);
    
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawRect(rect, borderPaint);
    
    // 模块名称
    final textPainter = TextPainter(
      text: TextSpan(
        text: module.moduleName,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left + 4, rect.top + 4));
  }
  
  void _drawNode(Canvas canvas, Size size, GraphNode node, bool isSelected) {
    final x = node.position['x']! * size.width;
    final y = node.position['y']! * size.height;
    final w = node.size['width']! * size.width;
    final h = node.size['height']! * size.height;
    
    // 填充
    final fillPaint = Paint()
      ..color = _hexToColor(node.color)
      ..style = PaintingStyle.fill;
    
    // 边框
    final borderPaint = Paint()
      ..color = isSelected ? Colors.blue : Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2 : 1;
    
    switch (node.shape) {
      case '椭圆形':
        canvas.drawOval(Rect.fromLTWH(x, y, w, h), fillPaint);
        canvas.drawOval(Rect.fromLTWH(x, y, w, h), borderPaint);
        break;
      case '菱形':
        final path = Path()
          ..moveTo(x + w / 2, y)
          ..lineTo(x + w, y + h / 2)
          ..lineTo(x + w / 2, y + h)
          ..lineTo(x, y + h / 2)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(4)),
          fillPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(4)),
          borderPaint,
        );
    }
    
    // 文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.nodeText,
        style: const TextStyle(color: Colors.black, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: w - 4);
    textPainter.paint(
      canvas,
      Offset(x + (w - textPainter.width) / 2, y + (h - textPainter.height) / 2),
    );
  }
  
  void _drawLine(Canvas canvas, Size size, GraphLine line, bool isSelected) {
    final startNode = graphData.nodeList.where((n) => n.nodeId == line.startNodeId).firstOrNull;
    final endNode = graphData.nodeList.where((n) => n.nodeId == line.endNodeId).firstOrNull;
    
    if (startNode == null || endNode == null) return;
    
    final x1 = (startNode.position['x']! + startNode.size['width']! / 2) * size.width;
    final y1 = (startNode.position['y']! + startNode.size['height']! / 2) * size.height;
    final x2 = (endNode.position['x']! + endNode.size['width']! / 2) * size.width;
    final y2 = (endNode.position['y']! + endNode.size['height']! / 2) * size.height;
    
    final paint = Paint()
      ..color = isSelected ? Colors.blue : _hexToColor(line.color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2 : 1.5;
    
    if (line.lineType == '虚线') {
      _drawDashedLine(canvas, Offset(x1, y1), Offset(x2, y2), paint);
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
    
    // 绘制箭头
    _drawArrow(canvas, Offset(x1, y1), Offset(x2, y2), paint, line.arrowType);
    
    // 线条文字
    if (line.lineText.isNotEmpty) {
      final mx = (x1 + x2) / 2;
      final my = (y1 + y2) / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: line.lineText,
          style: const TextStyle(color: Colors.black, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      // 文字背景
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(mx, my), width: textPainter.width + 4, height: textPainter.height + 2),
        bgPaint,
      );
      textPainter.paint(canvas, Offset(mx - textPainter.width / 2, my - textPainter.height / 2));
    }
  }
  
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = (Offset(dx, dy)).distance;
    final steps = (distance / (dashWidth + dashSpace)).floor();
    
    for (var i = 0; i < steps; i++) {
      final startRatio = i * (dashWidth + dashSpace) / distance;
      final endRatio = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      
      final lineStart = Offset(
        start.dx + dx * startRatio,
        start.dy + dy * startRatio,
      );
      final lineEnd = Offset(
        start.dx + dx * endRatio,
        start.dy + dy * endRatio,
      );
      
      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }
  
  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint, String arrowType) {
    if (arrowType == '无') return;
    
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = dx == 0 && dy == 0 ? 0.0 : (dy < 0 ? -1 : 1) * (dx == 0 ? 1.5708 : (dy / dx).abs() < 0.001 ? 0 : (dy / dx).abs() < 100 ? (dy / dx).abs() : 1.5708);
    
    // 简化的箭头绘制
    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(end.dx - 10, end.dy - 5);
    path.lineTo(end.dx - 10, end.dy + 5);
    path.close();
    
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }
  
  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.white;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

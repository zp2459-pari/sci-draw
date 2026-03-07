import 'package:flutter/material.dart';

import '../../models/graph_data.dart';
import '../../core/theme.dart';

/// 预览屏幕
class PreviewScreen extends StatefulWidget {
  final GraphData graphData;
  
  const PreviewScreen({super.key, required this.graphData});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  // 当前颜色方案
  int _currentColorScheme = 0;
  
  // 学术配色方案
  final List<List<Color>> _colorSchemes = [
    [Colors.black, Colors.grey],
    [Colors.blue.shade700, Colors.grey.shade400],
    [Colors.green.shade700, Colors.grey.shade400],
    [Colors.red.shade700, Colors.grey.shade400],
    [Colors.purple.shade700, Colors.grey.shade400],
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预览'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // 图表信息
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.graphData.graphInfo.graphType,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '目标: ${widget.graphData.graphInfo.targetJournal}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${widget.graphData.nodeList.length} 节点'),
                ),
              ],
            ),
          ),
          
          // 画布
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CustomPaint(
                size: const Size(800, 600),
                painter: GraphPainter(
                  graphData: widget.graphData,
                  colorScheme: _colorSchemes[_currentColorScheme],
                ),
                child: const SizedBox(width: 800, height: 600),
              ),
            ),
          ),
          
          // 底部操作栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.text_fields,
                    label: '编辑文字',
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.edit,
                    label: '调整布局',
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.palette,
                    label: '更换配色',
                    onTap: _showColorPicker,
                  ),
                  _ActionButton(
                    icon: Icons.download,
                    label: '导出',
                    onTap: _showExportOptions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择配色方案',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_colorSchemes.length, (index) {
                final colors = _colorSchemes[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentColorScheme = index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _currentColorScheme == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: _currentColorScheme == index ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导出格式',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('PNG (300DPI)'),
              subtitle: const Text('适合论文插入'),
              onTap: () {
                Navigator.pop(context);
                _exportFile('png');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('SVG'),
              subtitle: const Text('矢量图，可编辑'),
              onTap: () {
                Navigator.pop(context);
                _exportFile('svg');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              subtitle: const Text('适合出版'),
              onTap: () {
                Navigator.pop(context);
                _exportFile('pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_on),
              title: const Text('Visio (.vsdx)'),
              subtitle: const Text('可在 Visio 中编辑'),
              onTap: () {
                Navigator.pop(context);
                _exportFile('vsdx');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _exportFile(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在导出 $format 格式...')),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// 图表绘制 painter
class GraphPainter extends CustomPainter {
  final GraphData graphData;
  final List<Color> colorScheme;
  
  GraphPainter({
    required this.graphData,
    required this.colorScheme,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = colorScheme[0];
    final secondaryColor = colorScheme[1];
    
    // 绘制模块背景
    for (final module in graphData.moduleList) {
      _drawModule(canvas, size, module, secondaryColor.withOpacity(0.1));
    }
    
    // 绘制连接线
    for (final line in graphData.lineList) {
      _drawLine(canvas, size, line, primaryColor);
    }
    
    // 绘制节点
    for (final node in graphData.nodeList) {
      _drawNode(canvas, size, node, primaryColor);
    }
  }
  
  void _drawModule(Canvas canvas, Size size, GraphModule module, Color color) {
    final rect = Rect.fromLTWH(
      module.position['x']! * size.width,
      module.position['y']! * size.height,
      module.size['width']! * size.width,
      module.size['height']! * size.height,
    );
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(rect, paint);
    
    // 边框
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawRect(rect, borderPaint);
  }
  
  void _drawNode(Canvas canvas, Size size, GraphNode node, Color color) {
    final x = node.position['x']! * size.width;
    final y = node.position['y']! * size.height;
    final w = node.size['width']! * size.width;
    final h = node.size['height']! * size.height;
    
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // 根据形状绘制
    switch (node.shape) {
      case '椭圆形':
        canvas.drawOval(Rect.fromLTWH(x, y, w, h), paint);
        break;
      case '菱形':
        final path = Path()
          ..moveTo(x + w / 2, y)
          ..lineTo(x + w, y + h / 2)
          ..lineTo(x + w / 2, y + h)
          ..lineTo(x, y + h / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(4)),
          paint,
        );
    }
    
    // 边框
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    switch (node.shape) {
      case '椭圆形':
        canvas.drawOval(Rect.fromLTWH(x, y, w, h), borderPaint);
        break;
      case '菱形':
        final path = Path()
          ..moveTo(x + w / 2, y)
          ..lineTo(x + w, y + h / 2)
          ..lineTo(x + w / 2, y + h)
          ..lineTo(x, y + h / 2)
          ..close();
        canvas.drawPath(path, borderPaint);
        break;
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(4)),
          borderPaint,
        );
    }
    
    // 文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.nodeText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: w - 4);
    textPainter.paint(
      canvas,
      Offset(x + (w - textPainter.width) / 2, y + (h - textPainter.height) / 2),
    );
  }
  
  void _drawLine(Canvas canvas, Size size, GraphLine line, Color color) {
    // 简化实现：绘制直线
    // 实际需要根据 nodeId 查找节点位置
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    if (line.lineType == '虚线') {
      // TODO: 实现虚线
    }
    
    // 绘制箭头
    // TODO: 实现箭头
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

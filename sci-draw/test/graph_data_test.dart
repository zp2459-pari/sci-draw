import 'package:flutter_test/flutter_test.dart';

import 'package:sci_draw/models/graph_data.dart';

void main() {
  group('GraphData', () {
    test('should parse from JSON correctly', () {
      final json = {
        'graph_info': {
          'graph_type': '技术路线图',
          'target_journal': '通用SCI标准',
          'total_modules': 3,
          'read_direction': '从左到右'
        },
        'style_config': {
          'font_family': 'Arial',
          'main_color': ['#000000'],
          'line_width': '0.75pt',
          'dpi': 300
        },
        'node_list': [
          {
            'node_id': 'node_1',
            'module_id': 'module_1',
            'node_text': '文献综述',
            'node_type': '起始节点',
            'shape': '椭圆形',
            'position': {'x': 0.1, 'y': 0.2},
            'size': {'width': 0.15, 'height': 0.08},
            'color': '#FFFFFF'
          }
        ],
        'line_list': [],
        'module_list': []
      };

      final graphData = GraphData.fromJson(json);

      expect(graphData.graphInfo.graphType, '技术路线图');
      expect(graphData.nodeList.length, 1);
      expect(graphData.nodeList.first.nodeText, '文献综述');
    });
  });
}

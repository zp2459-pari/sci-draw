import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../models/graph_data.dart';
import 'storage_service.dart';

/// 大模型 API 服务
class LlmApiService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();
  
  /// 调用大模型生成绘图数据
  Future<GraphData> generateGraph({
    required String text,
    required String graphType,
    required String journalStandard,
  }) async {
    // 优先使用本地模拟生成（测试用）
    return _generateLocalMockData(text, graphType, journalStandard);
    
    // 实际 API 调用（需要配置 API Key）
    final config = _storage.getApiConfig();
    if (config == null) {
      throw Exception('请先配置 API Key');
    }
    
    final apiKey = await _storage.getApiKey('api_key');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('请先配置 API Key');
    }
    
    final provider = config['provider'] ?? 'openai';
    final model = config['model'] ?? 'gpt-4o';
    
    final prompt = _buildPrompt(text, graphType, journalStandard);
    
    String response;
    
    switch (provider) {
      case 'anthropic':
        response = await _callAnthropic(apiKey, model, prompt);
        break;
      case 'qwen':
        response = await _callQwen(apiKey, model, prompt);
        break;
      case 'wenxin':
        response = await _callWenxin(apiKey, model, prompt);
        break;
      default:
        response = await _callOpenAI(apiKey, model, prompt);
    }
    
    // 解析 JSON 响应
    return _parseJsonResponse(response);
  }
  
  /// 构建提示词
  String _buildPrompt(String text, String graphType, String journalStandard) {
    return '''【角色与任务】
你是顶级SCI顶刊科研绘图专家，精通Microsoft Visio科研绘图规范，唯一任务是：根据用户输入的科研文本，严格遵循以下所有规则，输出符合固定格式的结构化JSON绘图数据，禁止输出任何JSON之外的自然语言、解释、说明、备注，禁止添加任何原文未提及的内容、节点、逻辑关系。

【输入说明】
用户输入内容包括：科研核心文本、绘图类型、目标期刊规范、视觉预设，你必须100%基于输入内容生成，不得主观臆造、扩写、遗漏核心信息。

【绘图参数】
- 绘图类型：$graphType
- 目标期刊规范：$journalStandard

【科研文本】
$text

【输出强制规范】
1. 逻辑规范（红线要求）
    - 精准还原原文核心逻辑，因果、递进、并列、调控、对比关系完全匹配原文，主路径清晰，层级分明
    - 自动匹配对应绘图类型的标准布局，阅读顺序遵循学术惯例（默认从左到右、从上到下），无线条交叉、逻辑混乱
    - 线型与逻辑严格对应：
      实线单向箭头=直接作用/正向调控/流程推进
      虚线单向箭头=间接作用/潜在关联/辅助流程
      钝头/T型实线=直接抑制/负向调控
      钝头/T型虚线=间接抑制/潜在负向调控
      双向箭头=相互作用/反馈调节

2. 学术视觉规范（顶刊标准）
    - 配色：使用学术通用极简配色，主色不超过3种，优先黑白灰+1-2种低饱和强调色，确保黑白打印可清晰区分所有元素，禁止高饱和花哨配色
    - 字体：英文默认Arial，中文默认宋体，字号层级分明，标题字号＞节点正文＞标注文字，全图字体统一
    - 布局：节点间距均匀，模块划分清晰，复杂内容分模块标注，整体布局对称协调，符合Visio绘图标准

3. 输出格式强制要求
    仅输出以下固定结构的JSON，无任何其他内容''';
  }
  
  /// 调用 OpenAI API
  Future<String> _callOpenAI(String apiKey, String model, String prompt) async {
    try {
      final response = await _dio.post(
        '${AppConstants.openaiBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'system', 'content': '你是一个顶级SCI顶刊科研绘图专家。请严格按照JSON格式输出。'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.2,
        },
      );
      
      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      throw Exception('API 调用失败: $e');
    }
  }
  
  /// 调用 Anthropic API
  Future<String> _callAnthropic(String apiKey, String model, String prompt) async {
    try {
      final response = await _dio.post(
        '${AppConstants.anthropicBaseUrl}/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'max_tokens': 4096,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        },
      );
      
      return response.data['content'][0]['text'];
    } catch (e) {
      throw Exception('API 调用失败: $e');
    }
  }
  
  /// 调用通义千问 API
  Future<String> _callQwen(String apiKey, String model, String prompt) async {
    try {
      final response = await _dio.post(
        '${AppConstants.qwenBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'input': {
            'messages': [
              {'role': 'system', 'content': '你是一个顶级SCI顶刊科研绘图专家。请严格按照JSON格式输出。'},
              {'role': 'user', 'content': prompt}
            ]
          },
        },
      );
      
      return response.data['output']['text'];
    } catch (e) {
      throw Exception('API 调用失败: $e');
    }
  }
  
  /// 调用文心一言 API
  Future<String> _callWenxin(String apiKey, String model, String prompt) async {
    try {
      final response = await _dio.post(
        '${AppConstants.wenxinBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        },
      );
      
      return response.data['result'];
    } catch (e) {
      throw Exception('API 调用失败: $e');
    }
  }
  
  /// 解析 JSON 响应
  GraphData _parseJsonResponse(String response) {
    try {
      // 提取 JSON 部分
      String jsonStr = response.trim();
      if (jsonStr.contains('```json')) {
        jsonStr = jsonStr.split('```json')[1].split('```')[0];
      } else if (jsonStr.contains('```')) {
        jsonStr = jsonStr.split('```')[1].split('```')[0];
      }
      jsonStr = jsonStr.trim();
      
      final json = _parseJsonSafely(jsonStr);
      return GraphData.fromJson(json);
    } catch (e) {
      throw Exception('解析响应失败: $e');
    }
  }
  
  /// 安全解析 JSON
  Map<String, dynamic> _parseJsonSafely(String jsonStr) {
    // 处理 JSON 异常情况
    jsonStr = jsonStr.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    
    // 尝试直接解析
    try {
      return _jsonDecode(jsonStr);
    } catch (_) {}
    
    // 尝试提取 JSON 对象
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(jsonStr);
    if (match != null) {
      try {
        return _jsonDecode(match.group(0)!);
      } catch (_) {}
    }
    
    throw Exception('无法解析 JSON 响应');
  }
  
  /// 本地模拟生成测试数据
  GraphData _generateLocalMockData(String text, String graphType, String journalStandard) {
    // 基于输入文本提取关键词作为节点
    final words = text.replaceAll(RegExp(r'[^\w\s]'), '').split(RegExp(r'\s+'))
        .where((w) => w.length > 2).take(8).toList();
    
    if (words.isEmpty) {
      words.addAll(['输入', '处理', '输出', '结果']);
    }
    
    final nodes = <GraphNode>[];
    final lines = <GraphLine>[];
    final modules = <GraphModule>[];
    
    // 生成节点
    for (var i = 0; i < words.length; i++) {
      final col = i % 3;
      final row = i ~/ 3;
      nodes.add(GraphNode(
        nodeId: 'node_$i',
        moduleId: 'module_0',
        nodeText: words[i],
        nodeType: '流程节点',
        shape: i == 0 ? '椭圆形' : (i == words.length - 1 ? '菱形' : '矩形'),
        position: {'x': 0.1 + col * 0.35, 'y': 0.15 + row * 0.35},
        size: {'width': 0.25, 'height': 0.12},
        color: '#FFFFFF',
      ));
    }
    
    // 生成连线
    for (var i = 0; i < nodes.length - 1; i++) {
      lines.add(GraphLine(
        lineId: 'line_$i',
        startNodeId: nodes[i].nodeId,
        endNodeId: nodes[i + 1].nodeId,
        lineType: i % 2 == 0 ? '实线' : '虚线',
        arrowType: '单向箭头',
        lineText: i == 0 ? '核心过程' : '',
        color: '#333333',
      ));
    }
    
    // 添加一个模块
    modules.add(GraphModule(
      moduleId: 'module_0',
      moduleName: '流程模块',
      position: {'x': 0.05, 'y': 0.05},
      size: {'width': 0.9, 'height': 0.9},
    ));
    
    return GraphData(
      graphInfo: GraphInfo(
        graphType: graphType,
        targetJournal: journalStandard,
        totalModules: 1,
        readDirection: '从左到右',
      ),
      styleConfig: StyleConfig(
        fontFamily: 'Arial',
        mainColor: ['#2196F3', '#000000'],
        lineWidth: '0.75pt',
        dpi: 300,
      ),
      nodeList: nodes,
      lineList: lines,
      moduleList: modules,
    );
  }
  
  Map<String, dynamic> _jsonDecode(String source) {
    return _JsonDecoder(source).decode();
  }
}

/// 简单的 JSON 解析器
class _JsonDecoder {
  final String source;
  int pos = 0;
  
  _JsonDecoder(this.source);
  
  Map<String, dynamic> decode() {
    skipWhitespace();
    if (peek() != '{') throw FormatException('Expected {');
    return parseObject();
  }
  
  void skipWhitespace() {
    while (pos < source.length && ' \t\n\r'.contains(source[pos])) {
      pos++;
    }
  }
  
  String peek() => pos < source.length ? source[pos] : '';
  
  String read() => pos < source.length ? source[pos++] : '';
  
  Map<String, dynamic> parseObject() {
    final map = <String, dynamic>{};
    read(); // skip {
    skipWhitespace();
    
    while (peek() != '}') {
      if (peek() == ',') {
        read();
        skipWhitespace();
        continue;
      }
      
      // 解析 key
      skipWhitespace();
      String key;
      if (peek() == '"') {
        key = parseString();
      } else {
        // 可能是 bare key
        final start = pos;
        while (pos < source.length && source[pos] == ':') pos++;
        key = source.substring(start, pos).trim();
      }
      
      skipWhitespace();
      read(); // skip :
      skipWhitespace();
      
      // 解析 value
      map[key] = parseValue();
      
      skipWhitespace();
    }
    
    read(); // skip }
    return map;
  }
  
  dynamic parseValue() {
    skipWhitespace();
    final ch = peek();
    
    if (ch == '"') return parseString();
    if (ch == '{') return parseObject();
    if (ch == '[') return parseArray();
    if (ch == 't' || ch == 'f') return parseBool();
    if (ch == 'n') return parseNull();
    if (ch == '-' || (ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57)) return parseNumber();
    
    throw FormatException('Unexpected token: $ch');
  }
  
  String parseString() {
    read(); // skip "
    final buffer = StringBuffer();
    
    while (peek() != '"') {
      if (peek() == '\\') {
        read();
        switch (read()) {
          case 'n': buffer.write('\n'); break;
          case 't': buffer.write('\t'); break;
          case 'r': buffer.write('\r'); break;
          case '"': buffer.write('"'); break;
          case '\\': buffer.write('\\'); break;
          default: buffer.write(read());
        }
      } else {
        buffer.write(read());
      }
    }
    
    read(); // skip "
    return buffer.toString();
  }
  
  num parseNumber() {
    final start = pos;
    if (read() == '-') {}
    while (pos < source.length && '0123456789.eE+-'.contains(source[pos])) {
      pos++;
    }
    final numStr = source.substring(start, pos);
    return numStr.contains('.') ? double.parse(numStr) : int.parse(numStr);
  }
  
  bool parseBool() {
    if (source.substring(pos).startsWith('true')) {
      pos += 4;
      return true;
    }
    pos += 5;
    return false;
  }
  
  dynamic parseNull() {
    pos += 4;
    return null;
  }
  
  List<dynamic> parseArray() {
    final list = <dynamic>[];
    read(); // skip [
    skipWhitespace();
    
    while (peek() != ']') {
      if (peek() == ',') {
        read();
        skipWhitespace();
        continue;
      }
      list.add(parseValue());
      skipWhitespace();
    }
    
    read(); // skip ]
    return list;
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../models/graph_data.dart';
import '../../services/storage_service.dart';
import '../../services/llm_api_service.dart';
import '../preview/preview_screen.dart';

/// 创建图表屏幕
class CreateGraphScreen extends StatefulWidget {
  const CreateGraphScreen({super.key});

  @override
  State<CreateGraphScreen> createState() => _CreateGraphScreenState();
}

class _CreateGraphScreenState extends State<CreateGraphScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageService();
  final _llmApi = LlmApiService();
  
  String _selectedGraphType = AppConstants.graphTypes.first;
  String _selectedJournal = AppConstants.journalStandards.first;
  
  bool _isGenerating = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  Future<void> _generateGraph() async {
    if (!_formKey.currentState!.validate()) return;
    
    // 检查 API 配置
    final config = _storage.getApiConfig();
    if (config == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先配置 API Key'),
        ),
      );
      return;
    }
    
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    
    try {
      // 调用 API 生成图表
      final graphData = await _llmApi.generateGraph(
        text: _textController.text,
        graphType: _selectedGraphType,
        journalStandard: _selectedJournal,
      );
      
      // 保存项目
      final projectId = const Uuid().v4();
      await _storage.saveProject({
        'id': projectId,
        'title': _textController.text.substring(0, _textController.text.length.clamp(0, 20)),
        'text': _textController.text,
        'graphType': _selectedGraphType,
        'journalStandard': _selectedJournal,
        'graphData': graphData.toJson(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      // 跳转到预览
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewScreen(graphData: graphData),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建科研图'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 绘图类型选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '绘图类型',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGraphType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.graphTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedGraphType = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 期刊规范选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '目标期刊规范',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedJournal,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.menu_book),
                      ),
                      items: AppConstants.journalStandards
                          .map((journal) => DropdownMenuItem(
                                value: journal,
                                child: Text(journal),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedJournal = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 科研文本输入
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '科研文本',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '粘贴或输入需要绘图的科研内容',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _textController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: '例如：本研究首先进行文献综述，收集相关资料...\n然后进行实验设计，包括对照组和实验组...\n最后进行数据分析和结果讨论...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入科研文本';
                        }
                        if (value.length < 20) {
                          return '文本内容太少，请输入更详细的描述';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 示例文本按钮
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    _textController.text = '''本研究旨在探究某种药物对肿瘤细胞增殖的影响。首先，我们收集了100例肿瘤样本，分为实验组和对照组。实验组使用药物处理，对照组使用安慰剂处理。

然后，通过MTT实验检测细胞存活率，结果显示药物组细胞存活率明显低于对照组。Western blot检测显示药物处理后凋亡相关蛋白Bax表达上调，Bcl-2表达下调。

最后，动物实验进一步证实了该药物的抗肿瘤效果，且未见明显副作用。结论：该药物有望成为新的抗肿瘤药物。''';
                  },
                  child: const Text('示例：分子机制图'),
                ),
                TextButton(
                  onPressed: () {
                    _textController.text = '''本研究采用技术路线如下：
1. 文献调研阶段：通过CNKI、Web of Science等数据库收集相关文献
2. 理论分析阶段：建立数学模型，进行理论推导
3. 实验验证阶段：设计实验方案，开展室内实验
4. 数据处理阶段：使用SPSS和Python进行统计分析
5. 结论总结阶段：撰写论文，提交投稿''';
                  },
                  child: const Text('示例：技术路线图'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 错误提示
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            // 生成按钮
            FilledButton.icon(
              onPressed: _isGenerating ? null : _generateGraph,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? '生成中...' : '一键生成'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../services/storage_service.dart';

/// API 配置屏幕
class ApiConfigScreen extends StatefulWidget {
  const ApiConfigScreen({super.key});

  @override
  State<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  
  String _selectedProvider = 'openai';
  String _selectedModel = 'gpt-4o';
  bool _isLoading = false;
  bool _showApiKey = false;
  
  final Map<String, List<String>> _providerModels = {
    'openai': ['gpt-4o', 'gpt-4o-mini', 'gpt-4', 'gpt-3.5-turbo'],
    'anthropic': ['claude-sonnet-4-20250514', 'claude-3-5-sonnet-20241022', 'claude-3-opus-20240229'],
    'qwen': ['qwen-plus', 'qwen-turbo', 'qwen-long'],
    'wenxin': ['ernie-4.0-8k', 'ernie-3.5-8k'],
  };
  
  @override
  void initState() {
    super.initState();
    _loadConfig();
  }
  
  Future<void> _loadConfig() async {
    final config = StorageService().getApiConfig();
    if (config != null) {
      setState(() {
        _selectedProvider = config['provider'] ?? 'openai';
        _selectedModel = config['model'] ?? 'gpt-4o';
        _baseUrlController.text = config['baseUrl'] ?? '';
      });
      
      final apiKey = await StorageService().getApiKey('api_key');
      if (apiKey != null) {
        _apiKeyController.text = apiKey;
      }
    }
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }
  
  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // 保存 API Key（加密存储）
      await StorageService().saveApiKey('api_key', _apiKeyController.text);
      
      // 保存配置
      await StorageService().saveApiConfig({
        'provider': _selectedProvider,
        'model': _selectedModel,
        'baseUrl': _baseUrlController.text,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('配置已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _testConnection() async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入 API Key')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // TODO: 实现连通性测试
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('测试连接成功（模拟）')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API 配置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 提供商选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择大模型提供商',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('OpenAI'),
                          selected: _selectedProvider == 'openai',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedProvider = 'openai';
                                _selectedModel = 'gpt-4o';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Anthropic'),
                          selected: _selectedProvider == 'anthropic',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedProvider = 'anthropic';
                                _selectedModel = 'claude-sonnet-4-20250514';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('通义千问'),
                          selected: _selectedProvider == 'qwen',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedProvider = 'qwen';
                                _selectedModel = 'qwen-plus';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('文心一言'),
                          selected: _selectedProvider == 'wenxin',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedProvider = 'wenxin';
                                _selectedModel = 'ernie-4.0-8k';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 模型选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择模型',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedModel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _providerModels[_selectedProvider]!
                          .map((model) => DropdownMenuItem(
                                value: model,
                                child: Text(model),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedModel = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // API Key 输入
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Key',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      obscureText: !_showApiKey,
                      decoration: InputDecoration(
                        hintText: '输入你的 API Key',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showApiKey = !_showApiKey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入 API Key';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'API Key 仅存储在本地设备，不会上传至任何服务器',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 自定义端点（可选）
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '自定义端点（可选）',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        hintText: '如使用代理或自定义端点',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _testConnection,
                    icon: const Icon(Icons.wifi_tethering),
                    label: const Text('测试连接'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveConfig,
                    icon: const Icon(Icons.save),
                    label: const Text('保存配置'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

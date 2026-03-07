import 'package:flutter/material.dart';

import '../projects/projects_screen.dart';
import '../create_graph/create_graph_screen.dart';
import '../api_config/api_config_screen.dart';

/// 首页 - 应用入口
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const _HomeTab(),
    const ProjectsScreen(),
    const ApiConfigScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: '项目',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SciDraw'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 欢迎卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '科研绘图神器',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '输入科研文本，一键生成符合顶刊规范的科研图',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 开始绘图按钮
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGraphScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('开始绘图'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 功能介绍
              Expanded(
                child: ListView(
                  children: [
                    _FeatureCard(
                      icon: Icons.text_fields,
                      title: '文本输入',
                      description: '支持纯文本、论文段落导入',
                    ),
                    _FeatureCard(
                      icon: Icons.auto_awesome,
                      title: '一键生成',
                      description: 'AI 自动识别结构，生成标准科研图',
                    ),
                    _FeatureCard(
                      icon: Icons.edit,
                      title: '轻量编辑',
                      description: '支持节点、文字、线条微调',
                    ),
                    _FeatureCard(
                      icon: Icons.download,
                      title: '多格式导出',
                      description: 'Visio、SVG、PNG、PDF',
                    ),
                    _FeatureCard(
                      icon: Icons.security,
                      title: '隐私安全',
                      description: '数据 100% 本地存储',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme.dart';
import 'core/constants.dart';
import 'features/home/home_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  
  // 初始化存储服务
  await StorageService.init();
  
  runApp(const SciDrawApp());
}

class SciDrawApp extends StatelessWidget {
  const SciDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants.dart';

/// 存储服务 - 管理本地数据存储
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  late Box _apiConfigBox;
  late Box _projectsBox;
  late Box _settingsBox;
  
  /// 初始化
  static Future<void> init() async {
    final instance = StorageService();
    instance._apiConfigBox = await Hive.openBox(AppConstants.apiConfigBox);
    instance._projectsBox = await Hive.openBox(AppConstants.projectsBox);
    instance._settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }
  
  // ========== API 配置 ==========
  
  /// 保存 API 配置
  Future<void> saveApiConfig(Map<String, dynamic> config) async {
    await _apiConfigBox.put('current', config);
  }
  
  /// 获取 API 配置
  Map<String, dynamic>? getApiConfig() {
    return _apiConfigBox.get('current');
  }
  
  /// 安全存储 API Key
  Future<void> saveApiKey(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  /// 获取 API Key
  Future<String?> getApiKey(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  /// 删除 API Key
  Future<void> deleteApiKey(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  // ========== 项目管理 ==========
  
  /// 保存项目
  Future<void> saveProject(Map<String, dynamic> project) async {
    final id = project['id'];
    await _projectsBox.put(id, project);
  }
  
  /// 获取所有项目
  List<Map<String, dynamic>> getAllProjects() {
    return _projectsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => (b['updatedAt'] ?? 0).compareTo(a['updatedAt'] ?? 0));
  }
  
  /// 获取项目
  Map<String, dynamic>? getProject(String id) {
    final project = _projectsBox.get(id);
    return project != null ? Map<String, dynamic>.from(project) : null;
  }
  
  /// 删除项目
  Future<void> deleteProject(String id) async {
    await _projectsBox.delete(id);
  }
  
  // ========== 设置 ==========
  
  /// 保存设置
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  /// 获取设置
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
}

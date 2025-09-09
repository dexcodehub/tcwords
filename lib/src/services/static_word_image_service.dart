import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word.dart';

/// 静态单词图片服务
/// 管理预生成的单词图片资源
class StaticWordImageService {
  static final StaticWordImageService _instance = StaticWordImageService._internal();
  static StaticWordImageService get instance => _instance;
  
  StaticWordImageService._internal();
  
  Map<String, String>? _imageIndex;
  bool _initialized = false;
  
  /// 初始化图片索引
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // 加载图片索引文件
      final String indexData = await rootBundle.loadString('assets/images/words/index.json');
      _imageIndex = Map<String, String>.from(json.decode(indexData));
      _initialized = true;
      
      print('StaticWordImageService: 已加载 ${_imageIndex!.length} 张单词图片');
    } catch (e) {
      print('StaticWordImageService 初始化失败: $e');
      _imageIndex = {};
      _initialized = true;
    }
  }
  
  /// 获取单词图片路径
  String? getImagePath(String word) {
    if (!_initialized || _imageIndex == null) {
      return null;
    }
    
    // 尝试精确匹配
    String? path = _imageIndex![word.toLowerCase()];
    if (path != null) {
      return path;
    }
    
    // 尝试相似匹配（去掉复数形式等）
    String baseWord = _normalizeWord(word);
    path = _imageIndex![baseWord];
    if (path != null) {
      return path;
    }
    
    return null;
  }
  
  /// 获取单词图片路径（通过Word对象）
  String? getImagePathForWord(Word word) {
    return getImagePath(word.text);
  }
  
  /// 检查单词是否有图片
  bool hasImage(String word) {
    return getImagePath(word) != null;
  }
  
  /// 获取所有可用的单词图片
  Map<String, String> getAllImages() {
    return _imageIndex ?? {};
  }
  
  /// 获取图片统计信息
  Map<String, dynamic> getStatistics() {
    if (!_initialized || _imageIndex == null) {
      return {'total': 0, 'initialized': false};
    }
    
    return {
      'total': _imageIndex!.length,
      'initialized': true,
      'categories': _categorizeWords(),
    };
  }
  
  /// 标准化单词（处理复数、时态等）
  String _normalizeWord(String word) {
    String normalized = word.toLowerCase().trim();
    
    // 处理复数形式
    if (normalized.endsWith('s') && normalized.length > 3) {
      String singular = normalized.substring(0, normalized.length - 1);
      if (_imageIndex?.containsKey(singular) == true) {
        return singular;
      }
    }
    
    // 处理-ing形式
    if (normalized.endsWith('ing') && normalized.length > 5) {
      String base = normalized.substring(0, normalized.length - 3);
      if (_imageIndex?.containsKey(base) == true) {
        return base;
      }
    }
    
    // 处理-ed形式
    if (normalized.endsWith('ed') && normalized.length > 4) {
      String base = normalized.substring(0, normalized.length - 2);
      if (_imageIndex?.containsKey(base) == true) {
        return base;
      }
    }
    
    return normalized;
  }
  
  /// 按类别分类单词
  Map<String, int> _categorizeWords() {
    if (_imageIndex == null) return {};
    
    Map<String, int> categories = {};
    
    // 定义单词类别
    final Map<String, List<String>> categoryWords = {
      '动物': ['cat', 'dog', 'bird', 'fish', 'elephant', 'lion', 'tiger', 'bear', 'rabbit', 'horse', 'cow', 'pig', 'sheep', 'chicken', 'duck', 'monkey', 'panda', 'wolf', 'fox'],
      '食物': ['apple', 'banana', 'orange', 'bread', 'cake', 'pizza', 'milk', 'water', 'tea', 'coffee', 'rice', 'soup', 'meat'],
      '交通': ['car', 'bus', 'train', 'plane', 'bike', 'boat', 'ship', 'truck', 'taxi', 'helicopter'],
      '物品': ['book', 'pen', 'bag', 'phone', 'computer', 'watch', 'shoes', 'hat', 'chair', 'table', 'bed', 'door', 'window'],
      '自然': ['sun', 'moon', 'star', 'tree', 'flower', 'mountain', 'river', 'sea', 'forest'],
      '颜色': ['red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink', 'black', 'white'],
      '数字': ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten'],
    };
    
    // 统计各类别的图片数量
    for (String category in categoryWords.keys) {
      int count = 0;
      for (String word in categoryWords[category]!) {
        if (_imageIndex!.containsKey(word)) {
          count++;
        }
      }
      categories[category] = count;
    }
    
    return categories;
  }
  
  /// 预加载常用图片到内存（可选优化）
  Future<void> preloadCommonImages() async {
    // 这里可以实现图片预加载逻辑
    // 暂时为空，后续可根据需要优化
  }
}

/// 静态单词图片服务单例访问器
StaticWordImageService get staticWordImageService => StaticWordImageService.instance;
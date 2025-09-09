import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';

/// AI图片生成服务
/// 支持多种AI图片生成API，为单词学习提供视觉辅助
class AIImageService {
  static const String _cacheKeyPrefix = 'ai_image_cache_';
  static const String _settingsKey = 'ai_image_settings';
  
  // API配置
  static const Map<String, Map<String, String>> _apiConfigs = {
    'stability': {
      'url': 'https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image',
      'name': 'Stable Diffusion',
    },
    'pollinations': {
      'url': 'https://image.pollinations.ai/prompt/',
      'name': 'Pollinations AI (免费)',
    },
    'huggingface': {
      'url': 'https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5',
      'name': 'Hugging Face',
    },
  };
  
  String _currentProvider = 'pollinations'; // 默认使用免费服务
  String? _apiKey;
  bool _cacheEnabled = true;
  
  /// 初始化服务
  Future<void> initialize() async {
    await _loadSettings();
  }
  
  /// 为单词生成图片
  Future<String?> generateImageForWord(Word word) async {
    try {
      // 检查缓存
      if (_cacheEnabled) {
        final cachedPath = await _getCachedImagePath(word.text);
        if (cachedPath != null && await File(cachedPath).exists()) {
          return cachedPath;
        }
      }
      
      // 生成提示词
      final prompt = _generatePrompt(word);
      
      // 调用AI生成服务
      final imageData = await _generateImage(prompt);
      
      if (imageData != null) {
        // 保存到本地缓存
        final savedPath = await _saveImageToCache(word.text, imageData);
        return savedPath;
      }
      
      return null;
    } catch (e) {
      print('生成图片失败: $e');
      return null;
    }
  }
  
  /// 批量生成图片
  Future<Map<String, String?>> generateImagesForWords(List<Word> words) async {
    final results = <String, String?>{};
    
    for (final word in words) {
      final imagePath = await generateImageForWord(word);
      results[word.text] = imagePath;
      
      // 添加延迟避免API限制
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return results;
  }
  
  /// 生成优化的提示词
  String _generatePrompt(Word word) {
    // 基础提示词模板
    final basePrompt = word.text;
    
    // 根据单词类别和含义优化提示词
    String enhancedPrompt = basePrompt;
    
    if (word.meaning != null && word.meaning!.isNotEmpty) {
      // 添加中文含义帮助生成更准确的图片
      enhancedPrompt = '$basePrompt, ${word.meaning}';
    }
    
    // 添加风格描述
    enhancedPrompt += ', simple illustration, clean background, educational style, cartoon style, bright colors, clear and simple';
    
    // 根据单词类别添加特定描述
    switch (word.category.toLowerCase()) {
      case 'animals':
        enhancedPrompt += ', cute animal';
        break;
      case 'food':
        enhancedPrompt += ', delicious food item';
        break;
      case 'nature':
        enhancedPrompt += ', natural scene';
        break;
      case 'objects':
        enhancedPrompt += ', everyday object';
        break;
      default:
        enhancedPrompt += ', concept illustration';
    }
    
    return enhancedPrompt;
  }
  
  /// 调用AI生成图片
  Future<Uint8List?> _generateImage(String prompt) async {
    switch (_currentProvider) {
      case 'pollinations':
        return await _generateWithPollinations(prompt);
      case 'stability':
        return await _generateWithStability(prompt);
      case 'huggingface':
        return await _generateWithHuggingFace(prompt);
      default:
        return await _generateWithPollinations(prompt);
    }
  }
  
  /// 使用Pollinations AI生成图片（免费服务）
  Future<Uint8List?> _generateWithPollinations(String prompt) async {
    try {
      final encodedPrompt = Uri.encodeComponent(prompt);
      final url = '${_apiConfigs['pollinations']!['url']}$encodedPrompt';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TCWord/1.0',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      
      return null;
    } catch (e) {
      print('Pollinations AI请求失败: $e');
      return null;
    }
  }
  
  /// 使用Stability AI生成图片（需要API Key）
  Future<Uint8List?> _generateWithStability(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('Stability AI需要API Key');
      return null;
    }
    
    try {
      final response = await http.post(
        Uri.parse(_apiConfigs['stability']!['url']!),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'text_prompts': [
            {'text': prompt, 'weight': 1.0}
          ],
          'cfg_scale': 7,
          'height': 512,
          'width': 512,
          'samples': 1,
          'steps': 20,
        }),
      ).timeout(const Duration(seconds: 60));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final base64Image = data['artifacts'][0]['base64'];
        return base64Decode(base64Image);
      }
      
      return null;
    } catch (e) {
      print('Stability AI请求失败: $e');
      return null;
    }
  }
  
  /// 使用Hugging Face生成图片
  Future<Uint8List?> _generateWithHuggingFace(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiConfigs['huggingface']!['url']!),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': prompt,
          'parameters': {
            'num_inference_steps': 20,
            'guidance_scale': 7.5,
          }
        }),
      ).timeout(const Duration(seconds: 60));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      
      return null;
    } catch (e) {
      print('Hugging Face请求失败: $e');
      return null;
    }
  }
  
  /// 保存图片到缓存
  Future<String?> _saveImageToCache(String word, Uint8List imageData) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/ai_images');
      
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      
      final fileName = '${word.toLowerCase().replaceAll(' ', '_')}.png';
      final file = File('${cacheDir.path}/$fileName');
      
      await file.writeAsBytes(imageData);
      
      // 记录缓存信息
      await _saveCacheRecord(word, file.path);
      
      return file.path;
    } catch (e) {
      print('保存图片缓存失败: $e');
      return null;
    }
  }
  
  /// 获取缓存的图片路径
  Future<String?> _getCachedImagePath(String word) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix${word.toLowerCase()}';
      return prefs.getString(cacheKey);
    } catch (e) {
      return null;
    }
  }
  
  /// 保存缓存记录
  Future<void> _saveCacheRecord(String word, String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix${word.toLowerCase()}';
      await prefs.setString(cacheKey, imagePath);
    } catch (e) {
      print('保存缓存记录失败: $e');
    }
  }
  
  /// 清理缓存
  Future<void> clearCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/ai_images');
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      
      // 清理SharedPreferences中的缓存记录
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      print('AI图片缓存已清理');
    } catch (e) {
      print('清理缓存失败: $e');
    }
  }
  
  /// 设置API提供商
  Future<void> setProvider(String provider, {String? apiKey}) async {
    if (_apiConfigs.containsKey(provider)) {
      _currentProvider = provider;
      _apiKey = apiKey;
      await _saveSettings();
    }
  }
  
  /// 获取可用的提供商列表
  Map<String, String> getAvailableProviders() {
    return _apiConfigs.map((key, config) => MapEntry(key, config['name']!));
  }
  
  /// 检查服务状态
  Future<bool> isServiceAvailable() async {
    try {
      switch (_currentProvider) {
        case 'pollinations':
          final response = await http.head(
            Uri.parse(_apiConfigs['pollinations']!['url']!),
          ).timeout(const Duration(seconds: 10));
          return response.statusCode == 405; // Pollinations返回405但服务正常
        default:
          return true; // 其他服务假设可用
      }
    } catch (e) {
      return false;
    }
  }
  
  /// 获取当前设置
  Map<String, dynamic> getCurrentSettings() {
    return {
      'provider': _currentProvider,
      'providerName': _apiConfigs[_currentProvider]!['name']!,
      'hasApiKey': _apiKey != null && _apiKey!.isNotEmpty,
      'cacheEnabled': _cacheEnabled,
    };
  }
  
  /// 设置是否启用缓存
  Future<void> setCacheEnabled(bool enabled) async {
    _cacheEnabled = enabled;
    await _saveSettings();
  }
  
  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, json.encode({
        'provider': _currentProvider,
        'apiKey': _apiKey,
        'cacheEnabled': _cacheEnabled,
      }));
    } catch (e) {
      print('保存AI图片设置失败: $e');
    }
  }
  
  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settings = json.decode(settingsJson);
        _currentProvider = settings['provider'] ?? 'pollinations';
        _apiKey = settings['apiKey'];
        _cacheEnabled = settings['cacheEnabled'] ?? true;
      }
    } catch (e) {
      print('加载AI图片设置失败: $e');
    }
  }
}

/// AI图片生成服务单例
class AIImageServiceSingleton {
  static final AIImageServiceSingleton _instance = AIImageServiceSingleton._internal();
  static AIImageServiceSingleton get instance => _instance;
  
  AIImageServiceSingleton._internal();
  
  final AIImageService _service = AIImageService();
  
  Future<void> initialize() async {
    await _service.initialize();
  }
  
  AIImageService get service => _service;
}
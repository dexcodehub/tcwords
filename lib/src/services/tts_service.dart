import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  
  static Future<void> initialize() async {
    // 设置语言为英语
    await _flutterTts.setLanguage("en-US");
    
    // 设置语速（0.5为较慢，适合儿童）
    await _flutterTts.setSpeechRate(0.5);
    
    // 设置音调
    await _flutterTts.setPitch(1.0);
    
    // 设置音量
    await _flutterTts.setVolume(1.0);
  }
  
  // 朗读单词
  static Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }
  
  // 停止朗读
  static Future<void> stop() async {
    await _flutterTts.stop();
  }
  
  // 暂停朗读
  static Future<void> pause() async {
    await _flutterTts.pause();
  }
  
  // 获取系统支持的语言列表
  static Future<List<String>?> getLanguages() async {
    return await _flutterTts.getLanguages;
  }
  
  // 设置完成回调
  static void setCompletionHandler(VoidCallback callback) {
    _flutterTts.setCompletionHandler(callback);
  }
  
  // 设置开始回调
  static void setStartHandler(VoidCallback callback) {
    _flutterTts.setStartHandler(callback);
  }
  
  // 设置错误回调
  static void setErrorHandler(Function(dynamic) callback) {
    _flutterTts.setErrorHandler(callback);
  }
}
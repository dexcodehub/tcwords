import 'package:audioplayers/audioplayers.dart';
import 'package:tcword/src/services/tts_service.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  // 初始化音频服务
  static Future<void> initialize() async {
    await TTSService.initialize();
  }

  // 播放音频文件
  static Future<void> play(String path) async {
    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      // 在生产环境中，应该使用适当的日志记录而不是print
      // print('Error playing audio: $e');
    }
  }

  // 使用TTS朗读文本
  static Future<void> speak(String text) async {
    try {
      await TTSService.speak(text);
    } catch (e) {
      // 在生产环境中，应该使用适当的日志记录而不是print
      // print('Error speaking text: $e');
    }
  }

  // 停止播放
  static Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await TTSService.stop();
    } catch (e) {
      // 在生产环境中，应该使用适当的日志记录而不是print
      // print('Error stopping audio: $e');
    }
  }

  // 暂停播放
  static Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      await TTSService.pause();
    } catch (e) {
      // 在生产环境中，应该使用适当的日志记录而不是print
      // print('Error pausing audio: $e');
    }
  }

  // 恢复播放
  static Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      // 在生产环境中，应该使用适当的日志记录而不是print
      // print('Error resuming audio: $e');
    }
  }
  
  // 检查是否正在播放音频
  static Future<bool> isPlaying() async {
    return _audioPlayer.state == PlayerState.playing;
  }
}
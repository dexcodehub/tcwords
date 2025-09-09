import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/models/user_progress.dart';

class ProgressService {
  static const String _progressKey = 'user_progress';

  // 保存用户进度
  static Future<void> saveProgress(UserProgress progress) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(progress.toJson());
    await prefs.setString(_progressKey, jsonString);
  }

  // 获取用户进度
  static Future<UserProgress> getProgress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_progressKey);
    
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return UserProgress.fromJson(jsonMap);
    } else {
      // 如果没有保存的进度，返回一个新的UserProgress对象
      return UserProgress();
    }
  }

  // 添加积分
  static Future<void> addPoints(int points) async {
    final UserProgress progress = await getProgress();
    progress.addPoints(points);
    await saveProgress(progress);
  }

  // 标记单词已完成
  static Future<void> markWordAsCompleted(String wordId) async {
    final UserProgress progress = await getProgress();
    progress.markWordAsCompleted(wordId);
    await saveProgress(progress);
  }

  // 标记游戏已完成
  static Future<void> markGameAsCompleted(String gameId) async {
    final UserProgress progress = await getProgress();
    progress.markGameAsCompleted(gameId);
    await saveProgress(progress);
  }

  // 解锁奖励
  static Future<void> unlockReward(String rewardId) async {
    final UserProgress progress = await getProgress();
    progress.unlockReward(rewardId);
    await saveProgress(progress);
  }
}
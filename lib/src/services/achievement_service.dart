import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../data/achievements_data.dart';

/// 成就事件类型
enum AchievementEventType {
  wordLearned,
  gameCompleted,
  perfectScore,
  fastCompletion,
  dailyLogin,
  consecutiveCorrect,
}

/// 成就事件数据
class AchievementEvent {
  final AchievementEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  AchievementEvent({
    required this.type,
    this.data = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 成就服务
class AchievementService {
  static const String _storageKey = 'user_achievement_progress';
  static const String _statsKey = 'user_stats';
  
  UserAchievementProgress? _currentProgress;
  Map<String, int> _userStats = {};
  
  // 成就解锁事件流
  final StreamController<Achievement> _achievementUnlockedController =
      StreamController<Achievement>.broadcast();
  
  Stream<Achievement> get onAchievementUnlocked =>
      _achievementUnlockedController.stream;

  /// 初始化成就服务
  Future<void> initialize(String userId) async {
    await _loadUserProgress(userId);
    await _loadUserStats();
  }

  /// 获取用户成就进度
  UserAchievementProgress? get currentProgress => _currentProgress;

  /// 获取用户统计数据
  Map<String, int> get userStats => Map.unmodifiable(_userStats);

  /// 处理成就事件
  Future<List<Achievement>> processEvent(AchievementEvent event) async {
    if (_currentProgress == null) return [];

    // 更新用户统计数据
    await _updateUserStats(event);

    // 检查并更新相关成就
    final unlockedAchievements = <Achievement>[];
    
    for (final achievement in _currentProgress!.achievements.values) {
      if (achievement.isUnlocked) continue;

      bool shouldUpdate = false;
      Achievement updatedAchievement = achievement;

      // 根据事件类型更新成就条件
      for (final condition in achievement.conditions) {
        final newValue = _calculateConditionValue(condition.type, event);
        if (newValue != null && newValue != condition.currentValue) {
          updatedAchievement = updatedAchievement.updateCondition(
            condition.type,
            newValue,
          );
          shouldUpdate = true;
        }
      }

      if (shouldUpdate) {
        // 检查是否可以解锁
        if (updatedAchievement.canUnlock) {
          updatedAchievement = updatedAchievement.unlock();
          unlockedAchievements.add(updatedAchievement);
          
          // 发送解锁事件
          _achievementUnlockedController.add(updatedAchievement);
        }

        // 更新进度
        _currentProgress = _currentProgress!.updateAchievement(updatedAchievement);
      }
    }

    // 保存进度
    if (unlockedAchievements.isNotEmpty) {
      await _saveUserProgress();
    }

    return unlockedAchievements;
  }

  /// 根据条件类型计算新值
  int? _calculateConditionValue(String conditionType, AchievementEvent event) {
    switch (conditionType) {
      case 'words_learned':
        return _userStats['words_learned'] ?? 0;
      
      case 'games_completed':
        return _userStats['games_completed'] ?? 0;
      
      case 'perfect_scores':
        return _userStats['perfect_scores'] ?? 0;
      
      case 'fast_completions':
        return _userStats['fast_completions'] ?? 0;
      
      case 'consecutive_correct':
        if (event.type == AchievementEventType.consecutiveCorrect) {
          return event.data['count'] as int? ?? 0;
        }
        return null;
      
      case 'daily_streak':
        return _userStats['daily_streak'] ?? 0;
      
      case 'game_types_played':
        return _userStats['game_types_played'] ?? 0;
      
      case 'badges_collected':
        return _currentProgress?.unlockedBadges.length ?? 0;
      
      case 'total_stars':
        return _currentProgress?.totalStars ?? 0;
      
      case 'achievements_unlocked':
        return _currentProgress?.unlockedCount ?? 0;
      
      default:
        return null;
    }
  }

  /// 更新用户统计数据
  Future<void> _updateUserStats(AchievementEvent event) async {
    switch (event.type) {
      case AchievementEventType.wordLearned:
        _userStats['words_learned'] = (_userStats['words_learned'] ?? 0) + 1;
        break;
      
      case AchievementEventType.gameCompleted:
        _userStats['games_completed'] = (_userStats['games_completed'] ?? 0) + 1;
        
        // 更新游戏类型统计
        final gameType = event.data['game_type'] as String?;
        if (gameType != null) {
          final playedTypes = _userStats['game_types_played'] ?? 0;
          final typeKey = 'played_$gameType';
          if ((_userStats[typeKey] ?? 0) == 0) {
            _userStats['game_types_played'] = playedTypes + 1;
          }
          _userStats[typeKey] = (_userStats[typeKey] ?? 0) + 1;
        }
        break;
      
      case AchievementEventType.perfectScore:
        _userStats['perfect_scores'] = (_userStats['perfect_scores'] ?? 0) + 1;
        break;
      
      case AchievementEventType.fastCompletion:
        _userStats['fast_completions'] = (_userStats['fast_completions'] ?? 0) + 1;
        break;
      
      case AchievementEventType.dailyLogin:
        await _updateDailyStreak();
        break;
      
      case AchievementEventType.consecutiveCorrect:
        // 连续正确答题由外部管理，这里不更新
        break;
    }

    await _saveUserStats();
  }

  /// 更新每日连续登录
  Future<void> _updateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final lastLoginDate = prefs.getString('last_login_date');
    final currentStreak = _userStats['daily_streak'] ?? 0;
    
    if (lastLoginDate == null) {
      // 首次登录
      _userStats['daily_streak'] = 1;
    } else {
      final lastLogin = DateTime.parse(lastLoginDate);
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
      
      if (lastLoginDate == todayKey) {
        // 今天已经登录过了
        return;
      } else if (lastLoginDate == yesterdayKey) {
        // 连续登录
        _userStats['daily_streak'] = currentStreak + 1;
      } else {
        // 中断了连续登录
        _userStats['daily_streak'] = 1;
      }
    }
    
    await prefs.setString('last_login_date', todayKey);
  }

  /// 手动触发成就检查
  Future<List<Achievement>> checkAchievements() async {
    if (_currentProgress == null) return [];

    final unlockedAchievements = <Achievement>[];
    
    for (final achievement in _currentProgress!.achievements.values) {
      if (achievement.isUnlocked) continue;

      bool shouldUpdate = false;
      Achievement updatedAchievement = achievement;

      // 检查所有条件
      for (final condition in achievement.conditions) {
        final currentValue = _calculateConditionValue(
          condition.type,
          AchievementEvent(type: AchievementEventType.dailyLogin),
        );
        
        if (currentValue != null && currentValue != condition.currentValue) {
          updatedAchievement = updatedAchievement.updateCondition(
            condition.type,
            currentValue,
          );
          shouldUpdate = true;
        }
      }

      if (shouldUpdate) {
        if (updatedAchievement.canUnlock) {
          updatedAchievement = updatedAchievement.unlock();
          unlockedAchievements.add(updatedAchievement);
          _achievementUnlockedController.add(updatedAchievement);
        }

        _currentProgress = _currentProgress!.updateAchievement(updatedAchievement);
      }
    }

    if (unlockedAchievements.isNotEmpty) {
      await _saveUserProgress();
    }

    return unlockedAchievements;
  }

  /// 获取特定类型的成就
  List<Achievement> getAchievementsByType(AchievementType type) {
    if (_currentProgress == null) return [];
    
    return _currentProgress!.achievements.values
        .where((achievement) => achievement.type == type)
        .toList();
  }

  /// 获取已解锁的成就
  List<Achievement> getUnlockedAchievements() {
    if (_currentProgress == null) return [];
    
    return _currentProgress!.achievements.values
        .where((achievement) => achievement.isUnlocked)
        .toList();
  }

  /// 获取进行中的成就（有进度但未解锁）
  List<Achievement> getInProgressAchievements() {
    if (_currentProgress == null) return [];
    
    return _currentProgress!.achievements.values
        .where((achievement) => 
            !achievement.isUnlocked && 
            achievement.overallProgress > 0)
        .toList();
  }

  /// 获取可见的成就（非隐藏或已解锁）
  List<Achievement> getVisibleAchievements() {
    if (_currentProgress == null) return [];
    
    return _currentProgress!.achievements.values
        .where((achievement) => !achievement.isHidden || achievement.isUnlocked)
        .toList();
  }

  /// 重置用户进度（仅用于测试）
  Future<void> resetProgress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_storageKey}_$userId');
    await prefs.remove(_statsKey);
    
    _userStats.clear();
    await _loadUserProgress(userId);
  }

  /// 加载用户进度
  Future<void> _loadUserProgress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('${_storageKey}_$userId');
    
    if (progressJson != null) {
      try {
        final progressData = jsonDecode(progressJson);
        _currentProgress = UserAchievementProgress.fromJson(progressData);
      } catch (e) {
        // 如果加载失败，创建新的进度
        await _createNewProgress(userId);
      }
    } else {
      await _createNewProgress(userId);
    }
  }

  /// 创建新的用户进度
  Future<void> _createNewProgress(String userId) async {
    final allAchievements = AchievementsData.getAllAchievements();
    final achievementsMap = <String, Achievement>{};
    
    for (final achievement in allAchievements) {
      achievementsMap[achievement.id] = achievement;
    }
    
    _currentProgress = UserAchievementProgress(
      userId: userId,
      achievements: achievementsMap,
      lastUpdated: DateTime.now(),
    );
    
    await _saveUserProgress();
  }

  /// 保存用户进度
  Future<void> _saveUserProgress() async {
    if (_currentProgress == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final progressJson = jsonEncode(_currentProgress!.toJson());
    await prefs.setString('${_storageKey}_${_currentProgress!.userId}', progressJson);
  }

  /// 加载用户统计数据
  Future<void> _loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    
    if (statsJson != null) {
      try {
        final statsData = jsonDecode(statsJson) as Map<String, dynamic>;
        _userStats = statsData.map((key, value) => MapEntry(key, value as int));
      } catch (e) {
        _userStats = {};
      }
    } else {
      _userStats = {};
    }
  }

  /// 保存用户统计数据
  Future<void> _saveUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = jsonEncode(_userStats);
    await prefs.setString(_statsKey, statsJson);
  }

  /// 释放资源
  void dispose() {
    _achievementUnlockedController.close();
  }
}

/// 成就服务单例
class AchievementServiceSingleton {
  static AchievementService? _instance;
  
  static AchievementService get instance {
    _instance ??= AchievementService();
    return _instance!;
  }
  
  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}
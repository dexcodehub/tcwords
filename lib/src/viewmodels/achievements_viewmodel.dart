import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

/// 成就页面视图模型
class AchievementsViewModel extends ChangeNotifier {
  final AchievementService _achievementService = AchievementServiceSingleton.instance;
  
  bool _isLoading = true;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// 获取所有可见成就
  List<Achievement> get visibleAchievements {
    return _achievementService.getVisibleAchievements();
  }
  
  /// 获取已解锁成就数量
  int get unlockedCount {
    return _achievementService.currentProgress?.unlockedCount ?? 0;
  }
  
  /// 获取总成就数量
  int get totalCount {
    return _achievementService.currentProgress?.totalCount ?? 0;
  }
  
  /// 获取总星星数
  int get totalStars {
    return _achievementService.currentProgress?.totalStars ?? 0;
  }
  
  /// 获取完成百分比
  double get completionPercentage {
    return _achievementService.currentProgress?.completionPercentage ?? 0.0;
  }
  
  /// 获取已解锁的成就
  List<Achievement> get unlockedAchievements {
    return _achievementService.getUnlockedAchievements();
  }
  
  /// 获取进行中的成就
  List<Achievement> get inProgressAchievements {
    return _achievementService.getInProgressAchievements();
  }
  
  /// 根据类型获取成就
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievementService.getAchievementsByType(type)
        .where((achievement) => !achievement.isHidden || achievement.isUnlocked)
        .toList();
  }
  
  /// 初始化
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // 检查成就状态
      await _achievementService.checkAchievements();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 刷新数据
  Future<void> refresh() async {
    await initialize();
  }
}
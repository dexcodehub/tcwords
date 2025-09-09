/// 成就类型枚举
enum AchievementType {
  /// 学习相关成就
  learning,
  /// 游戏相关成就
  gaming,
  /// 连续学习成就
  streak,
  /// 特殊成就
  special,
}

/// 成就难度等级
enum AchievementDifficulty {
  /// 简单
  easy,
  /// 中等
  medium,
  /// 困难
  hard,
  /// 传奇
  legendary,
}

/// 成就奖励类型
enum RewardType {
  /// 星星奖励
  stars,
  /// 徽章奖励
  badge,
  /// 称号奖励
  title,
  /// 特殊道具
  item,
}

/// 成就奖励模型
class AchievementReward {
  final RewardType type;
  final String name;
  final String description;
  final String iconPath;
  final int value; // 奖励数量或价值

  const AchievementReward({
    required this.type,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'name': name,
        'description': description,
        'iconPath': iconPath,
        'value': value,
      };

  factory AchievementReward.fromJson(Map<String, dynamic> json) {
    return AchievementReward(
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.stars,
      ),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconPath: json['iconPath'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

/// 成就条件模型
class AchievementCondition {
  final String type; // 条件类型：words_learned, games_played, streak_days等
  final int targetValue; // 目标值
  final int currentValue; // 当前进度值
  final Map<String, dynamic>? additionalData; // 额外条件数据

  const AchievementCondition({
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.additionalData,
  });

  /// 获取完成进度百分比
  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// 是否已完成
  bool get isCompleted => currentValue >= targetValue;

  /// 更新当前进度
  AchievementCondition updateProgress(int newValue) {
    return AchievementCondition(
      type: type,
      targetValue: targetValue,
      currentValue: newValue,
      additionalData: additionalData,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'additionalData': additionalData,
      };

  factory AchievementCondition.fromJson(Map<String, dynamic> json) {
    return AchievementCondition(
      type: json['type'] ?? '',
      targetValue: json['targetValue'] ?? 0,
      currentValue: json['currentValue'] ?? 0,
      additionalData: json['additionalData'],
    );
  }
}

/// 成就模型
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final AchievementType type;
  final AchievementDifficulty difficulty;
  final List<AchievementCondition> conditions;
  final List<AchievementReward> rewards;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isHidden; // 是否为隐藏成就

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.difficulty,
    required this.conditions,
    required this.rewards,
    this.isUnlocked = false,
    this.unlockedAt,
    this.isHidden = false,
  });

  /// 获取总体完成进度
  double get overallProgress {
    if (conditions.isEmpty) return 0.0;
    double totalProgress = conditions
        .map((condition) => condition.progressPercentage)
        .reduce((a, b) => a + b);
    return totalProgress / conditions.length;
  }

  /// 是否可以解锁
  bool get canUnlock {
    return !isUnlocked && conditions.every((condition) => condition.isCompleted);
  }

  /// 解锁成就
  Achievement unlock() {
    return Achievement(
      id: id,
      name: name,
      description: description,
      iconPath: iconPath,
      type: type,
      difficulty: difficulty,
      conditions: conditions,
      rewards: rewards,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      isHidden: isHidden,
    );
  }

  /// 更新条件进度
  Achievement updateCondition(String conditionType, int newValue) {
    final updatedConditions = conditions.map((condition) {
      if (condition.type == conditionType) {
        return condition.updateProgress(newValue);
      }
      return condition;
    }).toList();

    return Achievement(
      id: id,
      name: name,
      description: description,
      iconPath: iconPath,
      type: type,
      difficulty: difficulty,
      conditions: updatedConditions,
      rewards: rewards,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      isHidden: isHidden,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconPath': iconPath,
        'type': type.name,
        'difficulty': difficulty.name,
        'conditions': conditions.map((c) => c.toJson()).toList(),
        'rewards': rewards.map((r) => r.toJson()).toList(),
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'isHidden': isHidden,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconPath: json['iconPath'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.learning,
      ),
      difficulty: AchievementDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => AchievementDifficulty.easy,
      ),
      conditions: (json['conditions'] as List<dynamic>? ?? [])
          .map((c) => AchievementCondition.fromJson(c))
          .toList(),
      rewards: (json['rewards'] as List<dynamic>? ?? [])
          .map((r) => AchievementReward.fromJson(r))
          .toList(),
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      isHidden: json['isHidden'] ?? false,
    );
  }
}

/// 用户成就进度模型
class UserAchievementProgress {
  final String userId;
  final Map<String, Achievement> achievements;
  final int totalStars;
  final List<String> unlockedBadges;
  final List<String> unlockedTitles;
  final DateTime lastUpdated;

  const UserAchievementProgress({
    required this.userId,
    required this.achievements,
    this.totalStars = 0,
    this.unlockedBadges = const [],
    this.unlockedTitles = const [],
    required this.lastUpdated,
  });

  /// 获取已解锁的成就数量
  int get unlockedCount {
    return achievements.values.where((a) => a.isUnlocked).length;
  }

  /// 获取总成就数量
  int get totalCount => achievements.length;

  /// 获取完成百分比
  double get completionPercentage {
    if (totalCount == 0) return 0.0;
    return unlockedCount / totalCount;
  }

  /// 更新成就进度
  UserAchievementProgress updateAchievement(Achievement achievement) {
    final updatedAchievements = Map<String, Achievement>.from(achievements);
    updatedAchievements[achievement.id] = achievement;

    // 计算新的星星总数
    int newTotalStars = totalStars;
    final newBadges = List<String>.from(unlockedBadges);
    final newTitles = List<String>.from(unlockedTitles);

    if (achievement.isUnlocked && !achievements[achievement.id]!.isUnlocked) {
      // 新解锁的成就，添加奖励
      for (final reward in achievement.rewards) {
        switch (reward.type) {
          case RewardType.stars:
            newTotalStars += reward.value;
            break;
          case RewardType.badge:
            if (!newBadges.contains(reward.name)) {
              newBadges.add(reward.name);
            }
            break;
          case RewardType.title:
            if (!newTitles.contains(reward.name)) {
              newTitles.add(reward.name);
            }
            break;
          case RewardType.item:
            // 处理道具奖励
            break;
        }
      }
    }

    return UserAchievementProgress(
      userId: userId,
      achievements: updatedAchievements,
      totalStars: newTotalStars,
      unlockedBadges: newBadges,
      unlockedTitles: newTitles,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'achievements': achievements.map((k, v) => MapEntry(k, v.toJson())),
        'totalStars': totalStars,
        'unlockedBadges': unlockedBadges,
        'unlockedTitles': unlockedTitles,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory UserAchievementProgress.fromJson(Map<String, dynamic> json) {
    final achievementsMap = <String, Achievement>{};
    final achievementsJson = json['achievements'] as Map<String, dynamic>? ?? {};
    
    for (final entry in achievementsJson.entries) {
      achievementsMap[entry.key] = Achievement.fromJson(entry.value);
    }

    return UserAchievementProgress(
      userId: json['userId'] ?? '',
      achievements: achievementsMap,
      totalStars: json['totalStars'] ?? 0,
      unlockedBadges: List<String>.from(json['unlockedBadges'] ?? []),
      unlockedTitles: List<String>.from(json['unlockedTitles'] ?? []),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
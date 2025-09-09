import '../models/achievement.dart';

/// 预定义的成就数据
class AchievementsData {
  /// 获取所有预定义成就
  static List<Achievement> getAllAchievements() {
    return [
      // 学习相关成就
      _createFirstWordAchievement(),
      _createWordMasterAchievement(),
      _createVocabularyBuilderAchievement(),
      _createSmartLearnerAchievement(),
      
      // 游戏相关成就
      _createFirstGameAchievement(),
      _createGameMasterAchievement(),
      _createPerfectScoreAchievement(),
      _createSpeedyPlayerAchievement(),
      
      // 连续学习成就
      _createDailyLearnerAchievement(),
      _createWeeklyChampionAchievement(),
      _createMonthlyHeroAchievement(),
      
      // 特殊成就
      _createExplorerAchievement(),
      _createCollectorAchievement(),
      _createSuperStarAchievement(),
      _createLegendaryLearnerAchievement(),
    ];
  }

  /// 第一个单词 - 学会第一个单词
  static Achievement _createFirstWordAchievement() {
    return Achievement(
      id: 'first_word',
      name: '第一个单词 🌟',
      description: '恭喜你学会了第一个单词！学习之旅开始啦！',
      iconPath: 'assets/icons/achievements/first_word.svg',
      type: AchievementType.learning,
      difficulty: AchievementDifficulty.easy,
      conditions: [
        AchievementCondition(
          type: 'words_learned',
          targetValue: 1,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得5颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 5,
        ),
        AchievementReward(
          type: RewardType.badge,
          name: '新手徽章',
          description: '学习新手徽章',
          iconPath: 'assets/icons/badges/beginner.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 单词大师 - 学会50个单词
  static Achievement _createWordMasterAchievement() {
    return Achievement(
      id: 'word_master',
      name: '单词大师 📚',
      description: '哇！你已经学会了50个单词，真是太棒了！',
      iconPath: 'assets/icons/achievements/word_master.svg',
      type: AchievementType.learning,
      difficulty: AchievementDifficulty.medium,
      conditions: [
        AchievementCondition(
          type: 'words_learned',
          targetValue: 50,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得20颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 20,
        ),
        AchievementReward(
          type: RewardType.badge,
          name: '单词大师徽章',
          description: '单词学习大师徽章',
          iconPath: 'assets/icons/badges/word_master.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 词汇建造师 - 学会100个单词
  static Achievement _createVocabularyBuilderAchievement() {
    return Achievement(
      id: 'vocabulary_builder',
      name: '词汇建造师 🏗️',
      description: '你的词汇库越来越丰富了！已经掌握100个单词！',
      iconPath: 'assets/icons/achievements/vocabulary_builder.svg',
      type: AchievementType.learning,
      difficulty: AchievementDifficulty.hard,
      conditions: [
        AchievementCondition(
          type: 'words_learned',
          targetValue: 100,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得50颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 50,
        ),
        AchievementReward(
          type: RewardType.title,
          name: '词汇建造师',
          description: '词汇建造师称号',
          iconPath: 'assets/icons/titles/builder.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 聪明学习者 - 连续答对10题
  static Achievement _createSmartLearnerAchievement() {
    return Achievement(
      id: 'smart_learner',
      name: '聪明学习者 🧠',
      description: '连续答对10题，你真是太聪明了！',
      iconPath: 'assets/icons/achievements/smart_learner.svg',
      type: AchievementType.learning,
      difficulty: AchievementDifficulty.medium,
      conditions: [
        AchievementCondition(
          type: 'consecutive_correct',
          targetValue: 10,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得15颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 15,
        ),
      ],
    );
  }

  /// 游戏新手 - 完成第一个游戏
  static Achievement _createFirstGameAchievement() {
    return Achievement(
      id: 'first_game',
      name: '游戏新手 🎮',
      description: '完成了第一个游戏，游戏时间开始！',
      iconPath: 'assets/icons/achievements/first_game.svg',
      type: AchievementType.gaming,
      difficulty: AchievementDifficulty.easy,
      conditions: [
        AchievementCondition(
          type: 'games_completed',
          targetValue: 1,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得3颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 3,
        ),
      ],
    );
  }

  /// 游戏大师 - 完成50个游戏
  static Achievement _createGameMasterAchievement() {
    return Achievement(
      id: 'game_master',
      name: '游戏大师 🏆',
      description: '完成了50个游戏，你是真正的游戏大师！',
      iconPath: 'assets/icons/achievements/game_master.svg',
      type: AchievementType.gaming,
      difficulty: AchievementDifficulty.hard,
      conditions: [
        AchievementCondition(
          type: 'games_completed',
          targetValue: 50,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得30颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 30,
        ),
        AchievementReward(
          type: RewardType.badge,
          name: '游戏大师徽章',
          description: '游戏大师徽章',
          iconPath: 'assets/icons/badges/game_master.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 完美得分 - 获得满分
  static Achievement _createPerfectScoreAchievement() {
    return Achievement(
      id: 'perfect_score',
      name: '完美得分 💯',
      description: '获得了满分！你太厉害了！',
      iconPath: 'assets/icons/achievements/perfect_score.svg',
      type: AchievementType.gaming,
      difficulty: AchievementDifficulty.medium,
      conditions: [
        AchievementCondition(
          type: 'perfect_scores',
          targetValue: 1,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得10颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 10,
        ),
      ],
    );
  }

  /// 速度玩家 - 快速完成游戏
  static Achievement _createSpeedyPlayerAchievement() {
    return Achievement(
      id: 'speedy_player',
      name: '速度玩家 ⚡',
      description: '在30秒内完成游戏，你的速度真快！',
      iconPath: 'assets/icons/achievements/speedy_player.svg',
      type: AchievementType.gaming,
      difficulty: AchievementDifficulty.medium,
      conditions: [
        AchievementCondition(
          type: 'fast_completions',
          targetValue: 1,
          additionalData: {'time_limit': 30},
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得8颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 8,
        ),
      ],
    );
  }

  /// 每日学习者 - 连续学习3天
  static Achievement _createDailyLearnerAchievement() {
    return Achievement(
      id: 'daily_learner',
      name: '每日学习者 📅',
      description: '连续学习3天，养成了好习惯！',
      iconPath: 'assets/icons/achievements/daily_learner.svg',
      type: AchievementType.streak,
      difficulty: AchievementDifficulty.easy,
      conditions: [
        AchievementCondition(
          type: 'daily_streak',
          targetValue: 3,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得12颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 12,
        ),
      ],
    );
  }

  /// 周冠军 - 连续学习7天
  static Achievement _createWeeklyChampionAchievement() {
    return Achievement(
      id: 'weekly_champion',
      name: '周冠军 👑',
      description: '连续学习一整周，你是真正的冠军！',
      iconPath: 'assets/icons/achievements/weekly_champion.svg',
      type: AchievementType.streak,
      difficulty: AchievementDifficulty.medium,
      conditions: [
        AchievementCondition(
          type: 'daily_streak',
          targetValue: 7,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得25颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 25,
        ),
        AchievementReward(
          type: RewardType.badge,
          name: '周冠军徽章',
          description: '周冠军徽章',
          iconPath: 'assets/icons/badges/weekly_champion.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 月度英雄 - 连续学习30天
  static Achievement _createMonthlyHeroAchievement() {
    return Achievement(
      id: 'monthly_hero',
      name: '月度英雄 🦸',
      description: '连续学习30天，你是真正的学习英雄！',
      iconPath: 'assets/icons/achievements/monthly_hero.svg',
      type: AchievementType.streak,
      difficulty: AchievementDifficulty.legendary,
      conditions: [
        AchievementCondition(
          type: 'daily_streak',
          targetValue: 30,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得100颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 100,
        ),
        AchievementReward(
          type: RewardType.title,
          name: '学习英雄',
          description: '学习英雄称号',
          iconPath: 'assets/icons/titles/hero.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 探索者 - 尝试所有游戏类型
  static Achievement _createExplorerAchievement() {
    return Achievement(
      id: 'explorer',
      name: '探索者 🗺️',
      description: '尝试了所有类型的游戏，真是个小探险家！',
      iconPath: 'assets/icons/achievements/explorer.svg',
      type: AchievementType.special,
      difficulty: AchievementDifficulty.medium,
      conditions: [
        AchievementCondition(
          type: 'game_types_played',
          targetValue: 3, // 假设有3种游戏类型
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得15颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 15,
        ),
        AchievementReward(
          type: RewardType.badge,
          name: '探索者徽章',
          description: '探索者徽章',
          iconPath: 'assets/icons/badges/explorer.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 收藏家 - 收集所有徽章
  static Achievement _createCollectorAchievement() {
    return Achievement(
      id: 'collector',
      name: '收藏家 🎖️',
      description: '收集了很多徽章，你是真正的收藏家！',
      iconPath: 'assets/icons/achievements/collector.svg',
      type: AchievementType.special,
      difficulty: AchievementDifficulty.hard,
      conditions: [
        AchievementCondition(
          type: 'badges_collected',
          targetValue: 10,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得40颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 40,
        ),
        AchievementReward(
          type: RewardType.title,
          name: '收藏大师',
          description: '收藏大师称号',
          iconPath: 'assets/icons/titles/collector.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 超级明星 - 获得500颗星星
  static Achievement _createSuperStarAchievement() {
    return Achievement(
      id: 'super_star',
      name: '超级明星 ⭐',
      description: '获得了500颗星星，你是真正的超级明星！',
      iconPath: 'assets/icons/achievements/super_star.svg',
      type: AchievementType.special,
      difficulty: AchievementDifficulty.hard,
      conditions: [
        AchievementCondition(
          type: 'total_stars',
          targetValue: 500,
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得50颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 50,
        ),
        AchievementReward(
          type: RewardType.title,
          name: '超级明星',
          description: '超级明星称号',
          iconPath: 'assets/icons/titles/super_star.svg',
          value: 1,
        ),
      ],
    );
  }

  /// 传奇学习者 - 隐藏成就
  static Achievement _createLegendaryLearnerAchievement() {
    return Achievement(
      id: 'legendary_learner',
      name: '传奇学习者 🌟',
      description: '完成了所有其他成就，你是传奇！',
      iconPath: 'assets/icons/achievements/legendary_learner.svg',
      type: AchievementType.special,
      difficulty: AchievementDifficulty.legendary,
      isHidden: true,
      conditions: [
        AchievementCondition(
          type: 'achievements_unlocked',
          targetValue: 14, // 除了这个成就外的所有成就
        ),
      ],
      rewards: [
        AchievementReward(
          type: RewardType.stars,
          name: '星星奖励',
          description: '获得200颗星星',
          iconPath: 'assets/icons/rewards/star.svg',
          value: 200,
        ),
        AchievementReward(
          type: RewardType.title,
          name: '传奇学习者',
          description: '传奇学习者称号',
          iconPath: 'assets/icons/titles/legendary.svg',
          value: 1,
        ),
        AchievementReward(
          type: RewardType.item,
          name: '黄金王冠',
          description: '专属黄金王冠',
          iconPath: 'assets/icons/items/golden_crown.svg',
          value: 1,
        ),
      ],
    );
  }
}
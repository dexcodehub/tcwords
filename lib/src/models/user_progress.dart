class UserProgress {
  int totalPoints;
  List<String> completedWords;
  List<String> completedGames;
  List<String> unlockedRewards;

  UserProgress({
    this.totalPoints = 0,
    this.completedWords = const [],
    this.completedGames = const [],
    this.unlockedRewards = const [],
  });

  // 添加积分
  void addPoints(int points) {
    totalPoints += points;
  }

  // 标记单词已完成
  void markWordAsCompleted(String wordId) {
    if (!completedWords.contains(wordId)) {
      completedWords.add(wordId);
    }
  }

  // 标记游戏已完成
  void markGameAsCompleted(String gameId) {
    if (!completedGames.contains(gameId)) {
      completedGames.add(gameId);
    }
  }

  // 解锁奖励
  void unlockReward(String rewardId) {
    if (!unlockedRewards.contains(rewardId)) {
      unlockedRewards.add(rewardId);
    }
  }

  // 从JSON创建UserProgress对象
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalPoints: json['totalPoints'] ?? 0,
      completedWords: List<String>.from(json['completedWords'] ?? []),
      completedGames: List<String>.from(json['completedGames'] ?? []),
      unlockedRewards: List<String>.from(json['unlockedRewards'] ?? []),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'completedWords': completedWords,
      'completedGames': completedGames,
      'unlockedRewards': unlockedRewards,
    };
  }
}
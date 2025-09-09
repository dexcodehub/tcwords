enum AchievementType {
  streak,
  lessons,
  experience,
  social,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final AchievementType type;
  final AchievementRarity rarity;
  final int requiredValue;
  final int experienceReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.rarity,
    required this.requiredValue,
    required this.experienceReward,
    required this.isUnlocked,
    this.unlockedAt,
    required this.progress,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.lessons,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      requiredValue: json['requiredValue'],
      experienceReward: json['experienceReward'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'type': type.name,
      'rarity': rarity.name,
      'requiredValue': requiredValue,
      'experienceReward': experienceReward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconUrl,
    AchievementType? type,
    AchievementRarity? rarity,
    int? requiredValue,
    int? experienceReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      requiredValue: requiredValue ?? this.requiredValue,
      experienceReward: experienceReward ?? this.experienceReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int experience;
  final int level;
  final int streak;
  final int rank;
  final bool isFriend;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.experience,
    required this.level,
    required this.streak,
    required this.rank,
    required this.isFriend,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      experience: json['experience'],
      level: json['level'],
      streak: json['streak'],
      rank: json['rank'],
      isFriend: json['isFriend'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'experience': experience,
      'level': level,
      'streak': streak,
      'rank': rank,
      'isFriend': isFriend,
    };
  }
}

enum FriendshipStatus {
  pending,
  accepted,
  blocked,
}

class Friend {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int experience;
  final int streak;
  final FriendshipStatus status;
  final DateTime createdAt;
  final bool isOnline;
  final DateTime? lastSeen;

  const Friend({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.experience,
    required this.streak,
    required this.status,
    required this.createdAt,
    required this.isOnline,
    this.lastSeen,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      level: json['level'],
      experience: json['experience'],
      streak: json['streak'],
      status: FriendshipStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendshipStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'level': level,
      'experience': experience,
      'streak': streak,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
}

enum ChallengeType {
  speed,
  accuracy,
  streak,
  endurance,
}

enum ChallengeStatus {
  pending,
  active,
  completed,
  expired,
}

class Challenge {
  final String id;
  final String challengerId;
  final String challengerName;
  final String? challengerAvatar;
  final String challengedId;
  final String challengedName;
  final String? challengedAvatar;
  final ChallengeType type;
  final ChallengeStatus status;
  final Map<String, dynamic> parameters;
  final Map<String, int> scores;
  final String? winnerId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? completedAt;

  const Challenge({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    this.challengerAvatar,
    required this.challengedId,
    required this.challengedName,
    this.challengedAvatar,
    required this.type,
    required this.status,
    required this.parameters,
    required this.scores,
    this.winnerId,
    required this.createdAt,
    required this.expiresAt,
    this.completedAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      challengerId: json['challengerId'],
      challengerName: json['challengerName'],
      challengerAvatar: json['challengerAvatar'],
      challengedId: json['challengedId'],
      challengedName: json['challengedName'],
      challengedAvatar: json['challengedAvatar'],
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.speed,
      ),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChallengeStatus.pending,
      ),
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      scores: Map<String, int>.from(json['scores'] ?? {}),
      winnerId: json['winnerId'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengerId': challengerId,
      'challengerName': challengerName,
      'challengerAvatar': challengerAvatar,
      'challengedId': challengedId,
      'challengedName': challengedName,
      'challengedAvatar': challengedAvatar,
      'type': type.name,
      'status': status.name,
      'parameters': parameters,
      'scores': scores,
      'winnerId': winnerId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
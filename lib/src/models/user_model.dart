class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int experience;
  final int streak;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final UserSettings settings;
  final UserProgress progress;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.experience,
    required this.streak,
    required this.createdAt,
    required this.lastLoginAt,
    required this.settings,
    required this.progress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      level: json['level'],
      experience: json['experience'],
      streak: json['streak'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      settings: UserSettings.fromJson(json['settings']),
      progress: UserProgress.fromJson(json['progress']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'level': level,
      'experience': experience,
      'streak': streak,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'settings': settings.toJson(),
      'progress': progress.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    int? level,
    int? experience,
    int? streak,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserSettings? settings,
    UserProgress? progress,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      streak: streak ?? this.streak,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? this.settings,
      progress: progress ?? this.progress,
    );
  }
}

class UserSettings {
  final bool soundEnabled;
  final bool notificationsEnabled;
  final String language;
  final int dailyGoal;
  final bool darkMode;

  const UserSettings({
    required this.soundEnabled,
    required this.notificationsEnabled,
    required this.language,
    required this.dailyGoal,
    required this.darkMode,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      soundEnabled: json['soundEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      language: json['language'] ?? 'en',
      dailyGoal: json['dailyGoal'] ?? 20,
      darkMode: json['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
      'language': language,
      'dailyGoal': dailyGoal,
      'darkMode': darkMode,
    };
  }

  UserSettings copyWith({
    bool? soundEnabled,
    bool? notificationsEnabled,
    String? language,
    int? dailyGoal,
    bool? darkMode,
  }) {
    return UserSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

class UserProgress {
  final int totalLessonsCompleted;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> skillLevels;
  final List<String> completedLessons;
  final DateTime? lastStudyDate;

  const UserProgress({
    required this.totalLessonsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.skillLevels,
    required this.completedLessons,
    this.lastStudyDate,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalLessonsCompleted: json['totalLessonsCompleted'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      skillLevels: Map<String, int>.from(json['skillLevels'] ?? {}),
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      lastStudyDate: json['lastStudyDate'] != null 
          ? DateTime.parse(json['lastStudyDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLessonsCompleted': totalLessonsCompleted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'skillLevels': skillLevels,
      'completedLessons': completedLessons,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
    };
  }

  UserProgress copyWith({
    int? totalLessonsCompleted,
    int? currentStreak,
    int? longestStreak,
    Map<String, int>? skillLevels,
    List<String>? completedLessons,
    DateTime? lastStudyDate,
  }) {
    return UserProgress(
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      skillLevels: skillLevels ?? this.skillLevels,
      completedLessons: completedLessons ?? this.completedLessons,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}
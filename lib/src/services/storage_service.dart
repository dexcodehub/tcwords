import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/achievement_model.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _guestModeKey = 'guest_mode';
  static const String _coursesKey = 'courses';
  static const String _progressKey = 'user_progress';
  static const String _achievementsKey = 'achievements';
  static const String _settingsKey = 'app_settings';
  static const String _streakKey = 'daily_streak';
  static const String _lastStudyDateKey = 'last_study_date';

  // User Management
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userData = json.decode(userJson);
        return User.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<bool> saveCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      return await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Error saving current user: $e');
      return false;
    }
  }

  Future<bool> clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_guestModeKey);
      return true;
    } catch (e) {
      print('Error clearing current user: $e');
      return false;
    }
  }

  // Guest Mode Management
  Future<bool> isGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_guestModeKey) ?? false;
    } catch (e) {
      print('Error checking guest mode: $e');
      return false;
    }
  }

  Future<bool> setGuestMode(bool isGuest) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_guestModeKey, isGuest);
    } catch (e) {
      print('Error setting guest mode: $e');
      return false;
    }
  }

  // Course Progress Management
  Future<List<LessonProgress>> getLessonProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);
      
      if (progressJson != null) {
        final progressList = json.decode(progressJson) as List;
        return progressList
            .map((progress) => LessonProgress.fromJson(progress))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting lesson progress: $e');
      return [];
    }
  }

  Future<bool> saveLessonProgress(List<LessonProgress> progressList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(
        progressList.map((progress) => progress.toJson()).toList(),
      );
      return await prefs.setString(_progressKey, progressJson);
    } catch (e) {
      print('Error saving lesson progress: $e');
      return false;
    }
  }

  Future<bool> updateLessonProgress(LessonProgress progress) async {
    try {
      final progressList = await getLessonProgress();
      final existingIndex = progressList.indexWhere(
        (p) => p.lessonId == progress.lessonId,
      );
      
      if (existingIndex >= 0) {
        progressList[existingIndex] = progress;
      } else {
        progressList.add(progress);
      }
      
      return await saveLessonProgress(progressList);
    } catch (e) {
      print('Error updating lesson progress: $e');
      return false;
    }
  }

  // Achievements Management
  Future<List<Achievement>> getAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);
      
      if (achievementsJson != null) {
        final achievementsList = json.decode(achievementsJson) as List;
        return achievementsList
            .map((achievement) => Achievement.fromJson(achievement))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting achievements: $e');
      return [];
    }
  }

  Future<bool> saveAchievements(List<Achievement> achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = json.encode(
        achievements.map((achievement) => achievement.toJson()).toList(),
      );
      return await prefs.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      print('Error saving achievements: $e');
      return false;
    }
  }

  Future<bool> unlockAchievement(String achievementId) async {
    try {
      final achievements = await getAchievements();
      final achievementIndex = achievements.indexWhere(
        (a) => a.id == achievementId,
      );
      
      if (achievementIndex >= 0) {
        achievements[achievementIndex] = achievements[achievementIndex].copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        return await saveAchievements(achievements);
      }
      
      return false;
    } catch (e) {
      print('Error unlocking achievement: $e');
      return false;
    }
  }

  // Streak Management
  Future<int> getCurrentStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_streakKey) ?? 0;
    } catch (e) {
      print('Error getting current streak: $e');
      return 0;
    }
  }

  Future<bool> updateStreak(int streak) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_streakKey, streak);
      await prefs.setString(_lastStudyDateKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      print('Error updating streak: $e');
      return false;
    }
  }

  Future<DateTime?> getLastStudyDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString(_lastStudyDateKey);
      
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
      
      return null;
    } catch (e) {
      print('Error getting last study date: $e');
      return null;
    }
  }

  // App Settings
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        return json.decode(settingsJson);
      }
      
      return {
        'soundEnabled': true,
        'notificationsEnabled': true,
        'darkMode': false,
        'language': 'en',
        'dailyGoal': 20,
      };
    } catch (e) {
      print('Error getting app settings: $e');
      return {};
    }
  }

  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings);
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving app settings: $e');
      return false;
    }
  }

  // Cache Management
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  Future<bool> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_coursesKey);
      await prefs.remove(_progressKey);
      return true;
    } catch (e) {
      print('Error clearing cache: $e');
      return false;
    }
  }
}
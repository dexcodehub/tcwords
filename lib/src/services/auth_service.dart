import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'https://api.tcword.com'; // Replace with actual API URL
  
  // 预设测试账号
  static final Map<String, Map<String, dynamic>> _testAccounts = {
    'test@tcword.com': {
      'password': '123456',
      'username': 'testuser',
      'displayName': '测试用户',
      'level': 3,
      'experience': 1250,
      'streak': 7,
    },
    'demo@tcword.com': {
      'password': 'demo123',
      'username': 'demouser',
      'displayName': '演示用户',
      'level': 5,
      'experience': 2800,
      'streak': 15,
    },
    'student@tcword.com': {
      'password': 'student',
      'username': 'student',
      'displayName': '学生用户',
      'level': 1,
      'experience': 150,
      'streak': 3,
    },
  };
  
  // 获取测试账号列表（用于登录界面显示）
  List<Map<String, String>> getTestAccounts() {
    return _testAccounts.entries.map((entry) {
      return {
        'email': entry.key,
        'password': entry.value['password'].toString(),
        'displayName': entry.value['displayName'].toString(),
        'description': '等级 ${entry.value['level']} • ${entry.value['experience']} XP • ${entry.value['streak']} 天连击',
      };
    }).toList();
  }
  
  Future<User> login(String email, String password) async {
    // 首先检查是否为测试账号
    if (_testAccounts.containsKey(email)) {
      final testAccount = _testAccounts[email]!;
      if (testAccount['password'] == password) {
        return _createTestUser(email, testAccount);
      } else {
        throw Exception('密码错误');
      }
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      // For demo purposes, return a mock user
      return _createMockUser(email);
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
          'displayName': displayName,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      // For demo purposes, return a mock user
      return _createMockUser(email, username: username, displayName: displayName);
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      // Handle logout error
      print('Logout error: $e');
    }
  }

  Future<User> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          if (displayName != null) 'displayName': displayName,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 创建测试用户
  User _createTestUser(String email, Map<String, dynamic> testAccount) {
    final now = DateTime.now();
    return User(
      id: 'test_${email.split('@')[0]}',
      email: email,
      username: testAccount['username'],
      displayName: testAccount['displayName'],
      level: testAccount['level'],
      experience: testAccount['experience'],
      streak: testAccount['streak'],
      createdAt: now.subtract(const Duration(days: 30)), // 模拟30天前注册
      lastLoginAt: now,
      settings: const UserSettings(
        soundEnabled: true,
        notificationsEnabled: true,
        language: 'zh',
        dailyGoal: 20,
        darkMode: false,
      ),
      progress: UserProgress(
        totalLessonsCompleted: testAccount['level'] * 10,
        currentStreak: testAccount['streak'],
        longestStreak: testAccount['streak'] + 5,
        skillLevels: {
          'vocabulary': testAccount['level'],
          'grammar': testAccount['level'] - 1,
          'listening': testAccount['level'],
          'speaking': testAccount['level'] - 1,
        },
        completedLessons: List.generate(
          testAccount['level'] * 10,
          (index) => 'lesson_$index',
        ),
      ),
    );
  }

  // Mock user creation for demo purposes
  User _createMockUser(String email, {String? username, String? displayName}) {
    final now = DateTime.now();
    return User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      username: username ?? email.split('@')[0],
      displayName: displayName ?? email.split('@')[0],
      level: 1,
      experience: 0,
      streak: 0,
      createdAt: now,
      lastLoginAt: now,
      settings: const UserSettings(
        soundEnabled: true,
        notificationsEnabled: true,
        language: 'en',
        dailyGoal: 20,
        darkMode: false,
      ),
      progress: const UserProgress(
        totalLessonsCompleted: 0,
        currentStreak: 0,
        longestStreak: 0,
        skillLevels: {},
        completedLessons: [],
      ),
    );
  }
}
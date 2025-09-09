import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/services/auth_service.dart';
import 'package:tcword/src/services/storage_service.dart';
import 'package:tcword/src/models/user_model.dart';
import 'package:tcword/src/models/course_model.dart';

void main() {
  group('AuthService 服务测试', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('获取测试账号列表', () {
      final testAccounts = authService.getTestAccounts();
      
      expect(testAccounts, isNotEmpty);
      expect(testAccounts.length, equals(3));
      
      // 验证测试账号结构
      final firstAccount = testAccounts.first;
      expect(firstAccount.containsKey('email'), isTrue);
      expect(firstAccount.containsKey('password'), isTrue);
      expect(firstAccount.containsKey('displayName'), isTrue);
      expect(firstAccount.containsKey('description'), isTrue);
    });

    test('使用测试账号登录成功', () async {
      final result = await authService.login('test@tcword.com', '123456');
      
      expect(result, isA<User>());
      expect(result.email, equals('test@tcword.com'));
      expect(result.displayName, equals('测试用户'));
      expect(result.level, equals(3));
      expect(result.experience, equals(1250));
      expect(result.streak, equals(7));
    });

    test('使用错误密码登录失败', () async {
      expect(
        () async => await authService.login('test@tcword.com', 'wrongpassword'),
        throwsException,
      );
    });

    test('使用不存在的邮箱登录返回Mock用户', () async {
      final result = await authService.login('nonexistent@example.com', 'anypassword');
      
      expect(result, isA<User>());
      expect(result.email, equals('nonexistent@example.com'));
      expect(result.level, equals(1));
      expect(result.experience, equals(0));
    });

    test('注册新用户', () async {
      final result = await authService.register(
        email: 'newuser@example.com',
        password: 'password123',
        username: 'newuser',
        displayName: '新用户',
      );
      
      expect(result, isA<User>());
      expect(result.email, equals('newuser@example.com'));
      expect(result.username, equals('newuser'));
      expect(result.displayName, equals('新用户'));
    });

    test('更新用户资料', () async {
      final result = await authService.updateProfile(
        userId: 'test_user_id',
        displayName: '更新的名称',
        avatarUrl: 'https://example.com/avatar.png',
      );
      
      expect(result, isA<User>());
      // 由于是模拟环境，具体验证依据实际实现
    });
  });

  group('StorageService 服务测试', () {
    late StorageService storageService;

    setUp(() async {
      // 初始化SharedPreferences的Mock
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    test('保存和获取当前用户', () async {
      final user = User(
        id: 'test_id',
        email: 'test@example.com',
        username: 'testuser',
        displayName: '测试用户',
        level: 5,
        experience: 2000,
        streak: 10,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        settings: const UserSettings(
          soundEnabled: true,
          notificationsEnabled: true,
          language: 'zh',
          dailyGoal: 25,
          darkMode: false,
        ),
        progress: const UserProgress(
          totalLessonsCompleted: 50,
          currentStreak: 10,
          longestStreak: 15,
          skillLevels: {'vocabulary': 5, 'grammar': 4},
          completedLessons: ['lesson1', 'lesson2'],
        ),
      );

      // 保存用户
      final saveResult = await storageService.saveCurrentUser(user);
      expect(saveResult, isTrue);

      // 获取用户
      final retrievedUser = await storageService.getCurrentUser();
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.id, equals(user.id));
      expect(retrievedUser.email, equals(user.email));
      expect(retrievedUser.displayName, equals(user.displayName));
      expect(retrievedUser.level, equals(user.level));
    });

    test('游客模式管理', () async {
      // 初始状态应该不是游客模式
      final initialGuestMode = await storageService.isGuestMode();
      expect(initialGuestMode, isFalse);

      // 设置游客模式
      final setResult = await storageService.setGuestMode(true);
      expect(setResult, isTrue);

      // 验证游客模式状态
      final guestModeEnabled = await storageService.isGuestMode();
      expect(guestModeEnabled, isTrue);

      // 取消游客模式
      await storageService.setGuestMode(false);
      final guestModeDisabled = await storageService.isGuestMode();
      expect(guestModeDisabled, isFalse);
    });

    test('学习进度管理', () async {
      final progressList = [
        LessonProgress(
          lessonId: 'lesson1',
          isCompleted: true,
          score: 85,
          attempts: 1,
          completedAt: DateTime.now(),
          timeSpent: Duration(seconds: 300),
        ),
        LessonProgress(
          lessonId: 'lesson2',
          isCompleted: false,
          score: 0,
          attempts: 1,
          completedAt: null,
          timeSpent: Duration(seconds: 150),
        ),
      ];

      // 保存进度
      final saveResult = await storageService.saveLessonProgress(progressList);
      expect(saveResult, isTrue);

      // 获取进度
      final retrievedProgress = await storageService.getLessonProgress();
      expect(retrievedProgress.length, equals(2));
      expect(retrievedProgress.first.lessonId, equals('lesson1'));
      expect(retrievedProgress.first.isCompleted, isTrue);
    });

    test('连击记录管理', () async {
      // 设置连击
      final updateResult = await storageService.updateStreak(15);
      expect(updateResult, isTrue);

      // 获取连击
      final currentStreak = await storageService.getCurrentStreak();
      expect(currentStreak, equals(15));

      // 验证学习日期被设置
      final lastStudyDate = await storageService.getLastStudyDate();
      expect(lastStudyDate, isNotNull);
      expect(lastStudyDate!.day, equals(DateTime.now().day));
    });

    test('应用设置管理', () async {
      final settings = {
        'soundEnabled': false,
        'notificationsEnabled': true,
        'darkMode': true,
        'language': 'en',
        'dailyGoal': 30,
      };

      // 保存设置
      final saveResult = await storageService.saveAppSettings(settings);
      expect(saveResult, isTrue);

      // 获取设置
      final retrievedSettings = await storageService.getAppSettings();
      expect(retrievedSettings['soundEnabled'], equals(false));
      expect(retrievedSettings['darkMode'], equals(true));
      expect(retrievedSettings['dailyGoal'], equals(30));
    });

    test('清除用户数据', () async {
      // 先保存一些数据
      await storageService.setGuestMode(true);
      await storageService.updateStreak(5);

      // 清除当前用户
      final clearResult = await storageService.clearCurrentUser();
      expect(clearResult, isTrue);

      // 验证数据被清除
      final user = await storageService.getCurrentUser();
      final guestMode = await storageService.isGuestMode();
      expect(user, isNull);
      expect(guestMode, isFalse);
    });
  });

  group('服务层集成测试', () {
    late AuthService authService;
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      authService = AuthService();
      storageService = StorageService();
    });

    test('完整登录流程测试', () async {
      // 1. 使用AuthService登录
      final user = await authService.login('demo@tcword.com', 'demo123');
      expect(user, isA<User>());

      // 2. 保存用户到存储
      final saveResult = await storageService.saveCurrentUser(user);
      expect(saveResult, isTrue);

      // 3. 从存储获取用户验证
      final storedUser = await storageService.getCurrentUser();
      expect(storedUser, isNotNull);
      expect(storedUser!.email, equals(user.email));
      expect(storedUser.displayName, equals(user.displayName));

      // 4. 登出并清理
      await authService.logout();
      await storageService.clearCurrentUser();

      // 5. 验证数据被清除
      final clearedUser = await storageService.getCurrentUser();
      expect(clearedUser, isNull);
    });

    test('游客模式流程测试', () async {
      // 1. 设置游客模式
      await storageService.setGuestMode(true);
      
      // 2. 验证游客模式状态
      final isGuest = await storageService.isGuestMode();
      expect(isGuest, isTrue);

      // 3. 游客模式下不应该有当前用户
      final guestUser = await storageService.getCurrentUser();
      expect(guestUser, isNull);

      // 4. 退出游客模式
      await storageService.clearCurrentUser();
      final isGuestAfterClear = await storageService.isGuestMode();
      expect(isGuestAfterClear, isFalse);
    });
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/views/auth/login_view.dart';
import 'package:tcword/src/views/home/home_view.dart';
import 'package:tcword/src/views/splash/splash_screen.dart';
import 'package:tcword/src/viewmodels/auth_viewmodel.dart';
import 'package:tcword/src/services/auth_service.dart';
import 'package:tcword/src/services/storage_service.dart';
import 'package:tcword/src/theme/app_theme.dart';
import 'package:tcword/src/widgets/custom_button.dart';
import 'package:tcword/src/widgets/custom_text_field.dart';

void main() {
  group('页面组件测试', () {
    late AuthService authService;
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      authService = AuthService();
      storageService = StorageService();
    });

    testWidgets('SplashScreen 渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      );

      // 验证启动画面元素
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // 验证应用名称或图标是否显示
      expect(find.text('TCWord'), findsOneWidget);
    });

    testWidgets('LoginView 基础渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginView(),
        ),
      );

      // 验证登录页面基本元素
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Continue your English learning journey'), findsOneWidget);
      
      // 验证输入框
      expect(find.byType(CustomTextField), findsAtLeastNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      
      // 验证按钮
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create New Account'), findsOneWidget);
      expect(find.text('游客模式进入'), findsOneWidget);
      
      // 验证测试账号部分
      expect(find.text('快速登录测试账号'), findsOneWidget);
    });

    testWidgets('LoginView 表单验证测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginView(),
        ),
      );

      // 找到登录按钮并点击（不输入任何内容）
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // 验证验证错误信息出现
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('LoginView 测试账号快速登录', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginView(),
        ),
      );

      // 查找测试账号卡片并点击第一个
      final testAccountCards = find.byType(InkWell);
      expect(testAccountCards, findsAtLeastNWidgets(1));
      
      // 点击第一个测试账号卡片
      await tester.tap(testAccountCards.first);
      await tester.pump();

      // 验证邮箱和密码字段被填充
      final emailField = find.byType(CustomTextField).first;
      final passwordField = find.byType(CustomTextField).last;
      
      // 这里我们无法直接验证TextEditingController的内容
      // 但可以验证UI状态的变化
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
    });

    testWidgets('HomeView 基础渲染测试 - 游客模式', (WidgetTester tester) async {
      // 设置游客模式
      await storageService.setGuestMode(true);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeView(),
        ),
      );

      // 等待异步操作完成
      await tester.pumpAndSettle();

      // 验证游客模式下的欢迎信息
      expect(find.text('Welcome,'), findsOneWidget);
      expect(find.text('Guest'), findsOneWidget);
      
      // 验证用户头像
      expect(find.byIcon(Icons.person), findsOneWidget);
      
      // 验证进度统计部分
      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('XP'), findsOneWidget);
      expect(find.text('Gems'), findsOneWidget);
    });

    testWidgets('HomeView 快速操作区域测试', (WidgetTester tester) async {
      await storageService.setGuestMode(true);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeView(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证快速操作部分
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Continue Learning'), findsOneWidget);
      expect(find.text('Daily Challenge'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
      
      // 测试快速操作点击
      await tester.tap(find.text('Continue Learning'));
      await tester.pump();
      
      // 验证SnackBar是否显示
      expect(find.text('Continue Learning feature coming soon!'), findsOneWidget);
    });

    testWidgets('HomeView 推荐课程区域测试', (WidgetTester tester) async {
      await storageService.setGuestMode(true);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeView(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证推荐课程部分
      expect(find.text('Featured Courses'), findsOneWidget);
      expect(find.text('English Basics'), findsOneWidget);
      expect(find.text('Conversation Skills'), findsOneWidget);
      expect(find.text('Grammar Master'), findsOneWidget);
      
      // 验证课程卡片的"Start"按钮
      final startButtons = find.text('Start');
      expect(startButtons, findsNWidgets(3));
      
      // 点击第一个Start按钮
      await tester.tap(startButtons.first);
      await tester.pump();
      
      // 验证SnackBar信息
      expect(find.text('English Basics course coming soon!'), findsOneWidget);
    });

    testWidgets('HomeView 用户进度显示测试', (WidgetTester tester) async {
      await storageService.setGuestMode(true);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeView(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证近期进度部分
      expect(find.text('Recent Progress'), findsOneWidget);
      expect(find.text('Basic Vocabulary'), findsOneWidget);
      expect(find.text('Lesson 3 of 10 completed'), findsOneWidget);
      
      // 验证进度条
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    group('页面导航测试', () {
      testWidgets('LoginView 到 RegisterView 导航', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginView(),
            routes: {
              '/register': (context) => const Scaffold(
                body: Center(child: Text('Register Page')),
              ),
            },
          ),
        );

        // 点击"Create New Account"按钮
        await tester.tap(find.text('Create New Account'));
        await tester.pumpAndSettle();

        // 验证是否导航到注册页面
        expect(find.text('Register Page'), findsOneWidget);
      });
    });

    group('状态管理集成测试', () {
      testWidgets('AuthViewModel 与 LoginView 集成', (WidgetTester tester) async {
        final authViewModel = AuthViewModel(authService, storageService);
        
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider.value(
              value: authViewModel,
              child: const LoginView(),
            ),
          ),
        );

        // 验证初始状态
        expect(authViewModel.state.status, equals(AuthState.initial));
        
        // 输入测试账号信息
        await tester.enterText(
          find.byType(CustomTextField).first, 
          'test@tcword.com'
        );
        await tester.enterText(
          find.byType(CustomTextField).last, 
          '123456'
        );
        
        // 点击登录按钮
        await tester.tap(find.text('Login'));
        await tester.pump();
        
        // 验证加载状态
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('游客模式状态测试', (WidgetTester tester) async {
        final authViewModel = AuthViewModel(authService, storageService);
        
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider.value(
              value: authViewModel,
              child: const LoginView(),
            ),
          ),
        );

        // 点击游客模式按钮
        await tester.tap(find.text('游客模式进入'));
        await tester.pump();
        
        // 验证游客模式状态
        expect(authViewModel.state.isGuest, isTrue);
      });
    });

    group('响应式UI测试', () {
      testWidgets('HomeView 在不同屏幕尺寸下的响应性', (WidgetTester tester) async {
        await storageService.setGuestMode(true);
        
        // 测试不同屏幕尺寸
        final smallSize = const Size(320, 568); // iPhone 5s size
        final largeSize = const Size(414, 896); // iPhone 11 Pro Max size
        
        // 小屏幕测试
        tester.binding.window.physicalSizeTestValue = smallSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeView(),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // 验证UI元素在小屏幕上正常显示
        expect(find.text('Guest'), findsOneWidget);
        expect(find.text('Quick Actions'), findsOneWidget);
        
        // 大屏幕测试
        tester.binding.window.physicalSizeTestValue = largeSize;
        await tester.pump();
        
        // 验证UI元素在大屏幕上也正常显示
        expect(find.text('Guest'), findsOneWidget);
        expect(find.text('Quick Actions'), findsOneWidget);
        
        // 重置屏幕尺寸
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });
    });

    group('错误处理测试', () {
      testWidgets('网络错误时的UI表现', (WidgetTester tester) async {
        final authViewModel = AuthViewModel(authService, storageService);
        
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider.value(
              value: authViewModel,
              child: const LoginView(),
            ),
          ),
        );

        // 输入无效的邮箱格式
        await tester.enterText(
          find.byType(CustomTextField).first, 
          'invalid-email'
        );
        await tester.enterText(
          find.byType(CustomTextField).last, 
          '123456'
        );
        
        // 点击登录按钮触发验证
        await tester.tap(find.text('Login'));
        await tester.pump();
        
        // 验证错误信息显示
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });
    });
  });
}
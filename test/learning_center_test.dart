import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/views/learning_center_view.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('LearningCenter测试', () {
    testWidgets('学习中心基础渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      // 等待加载完成
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证学习中心组件存在
      expect(find.byType(LearningCenterView), findsOneWidget);
    });

    testWidgets('学习中心数据加载测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      // 验证初始加载状态
      expect(find.text('Loading your learning journey...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 等待数据加载
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证加载完成后的UI
      expect(find.byType(LearningCenterView), findsOneWidget);
    });

    testWidgets('欢迎区域显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      // 等待加载完成
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证欢迎文本
      expect(find.text('欢迎回来！'), findsOneWidget);
      expect(find.text('继续你的英语学习之旅'), findsOneWidget);
    });

    testWidgets('每日目标区域测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      // 等待加载完成
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证每日目标相关文本
      expect(find.text('今日目标'), findsOneWidget);
    });

    testWidgets('学习模式区域测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      // 等待加载完成
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证学习模式标题和选项
      expect(find.text('学习模式'), findsOneWidget);
      expect(find.text('单词卡片'), findsOneWidget);
      expect(find.text('词汇测验'), findsOneWidget);
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.text('搜索单词'), findsOneWidget);
    });

    testWidgets('游戏模式区域测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      // 等待加载完成
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证游戏模式
      expect(find.text('游戏模式'), findsOneWidget);
      expect(find.text('单词配对'), findsOneWidget);
      expect(find.text('单词拼图'), findsOneWidget);
    });

    testWidgets('学习工具区域测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      // 等待加载完成
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证学习工具
      expect(find.text('学习工具'), findsOneWidget);
      expect(find.text('学习进度'), findsOneWidget);
    });

    testWidgets('响应式布局测试', (WidgetTester tester) async {
      // 测试小屏幕
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证在小屏幕上正常显示
      expect(find.byType(LearningCenterView), findsOneWidget);

      // 重置屏幕尺寸
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('动画效果测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningCenterView(),
        ),
      );

      // 验证初始状态
      expect(find.byType(LearningCenterView), findsOneWidget);
      
      // 等待动画完成
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 验证动画后的状态
      expect(find.byType(LearningCenterView), findsOneWidget);
    });
  });
}
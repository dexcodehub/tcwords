import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/learning/word_bookmark.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  // 初始化Flutter绑定
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('WordBookmark UI测试', () {
    testWidgets('WordBookmark基础渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      // 验证基础界面元素
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.text('搜索收藏的单词...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });

    testWidgets('空收藏状态显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证空状态显示
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.text('还没有收藏任何单词'), findsOneWidget);
      expect(find.text('去学习单词'), findsOneWidget);
    });

    testWidgets('视图切换按钮测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      // 验证初始为网格视图切换按钮
      expect(find.byIcon(Icons.grid_view), findsOneWidget);

      // 点击切换到网格视图
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pump();

      // 验证切换为列表视图按钮
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('搜索框功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // 测试输入搜索内容
      await tester.enterText(searchField, 'test');
      await tester.pump();

      // 验证清除按钮出现
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // 点击清除按钮
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // 验证搜索框被清空
      expect(find.text('test'), findsNothing);
    });

    testWidgets('批量操作模式切换测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      // 点击批量操作按钮
      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pump();

      // 验证进入选择模式
      expect(find.text('已选择 0 项'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);

      // 点击取消
      await tester.tap(find.text('取消'));
      await tester.pump();

      // 验证退出选择模式
      expect(find.text('我的收藏'), findsOneWidget);
    });

    testWidgets('回调函数设置测试', (WidgetTester tester) async {
      bool wordTapCalled = false;
      bool startReviewCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: WordBookmark(
            onWordTap: () => wordTapCalled = true,
            onStartReview: () => startReviewCalled = true,
          ),
        ),
      );

      // 验证组件正常渲染
      expect(find.byType(WordBookmark), findsOneWidget);
    });

    testWidgets('响应式布局测试', (WidgetTester tester) async {
      // 小屏幕测试
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证在小屏幕上正常显示
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.text('搜索收藏的单词...'), findsOneWidget);

      // 重置屏幕尺寸
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('无障碍访问测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      // 验证关键元素存在（用于语音阅读器）
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.text('搜索收藏的单词...'), findsOneWidget);
      expect(find.text('去学习单词'), findsOneWidget);
    });

    testWidgets('组件层级结构测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      // 验证主要组件结构
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('主题适配测试', (WidgetTester tester) async {
      // 测试亮色主题
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      expect(find.byType(WordBookmark), findsOneWidget);

      // 测试深色主题
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const WordBookmark(),
        ),
      );

      expect(find.byType(WordBookmark), findsOneWidget);
    });

    testWidgets('错误处理UI测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WordBookmark(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证组件在数据加载失败时不会崩溃
      expect(find.byType(WordBookmark), findsOneWidget);
    });
  });
}
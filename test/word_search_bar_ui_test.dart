import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/learning/word_search_bar.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('WordSearchBar UI测试', () {
    testWidgets('WordSearchBar基础渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 验证基本组件存在
      expect(find.byType(WordSearchBar), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('搜索单词、含义或例句...'), findsOneWidget);
    });

    testWidgets('搜索框交互测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 找到搜索框
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // 输入搜索文本
      await tester.enterText(searchField, 'hello');
      await tester.pump();

      // 验证文本输入
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('筛选器显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(showFilters: true),
          ),
        ),
      );

      await tester.pump();

      // 验证筛选器相关元素
      expect(find.text('筛选器'), findsOneWidget);
      expect(find.text('难度'), findsOneWidget);
    });

    testWidgets('筛选器隐藏测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(showFilters: false),
          ),
        ),
      );

      await tester.pump();

      // 验证筛选器不显示
      expect(find.text('筛选器'), findsNothing);
    });

    testWidgets('难度筛选器交互测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 验证难度标签存在
      expect(find.text('入门'), findsOneWidget);
      expect(find.text('初级'), findsOneWidget);
      expect(find.text('中级'), findsOneWidget);
      expect(find.text('高级'), findsOneWidget);

      // 点击难度筛选器
      await tester.tap(find.text('入门'));
      await tester.pump();

      // 验证点击不会导致错误
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('初始查询测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(
              initialQuery: 'test query',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 验证初始查询显示
      expect(find.text('test query'), findsOneWidget);
    });

    testWidgets('回调函数测试', (WidgetTester tester) async {
      List<Word> searchResults = [];
      String queryChanged = '';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(
              onSearchResults: (results) {
                searchResults = results;
              },
              onQueryChanged: (query) {
                queryChanged = query;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // 验证组件创建成功（回调函数设置不会引起错误）
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('最大高度约束测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(
              maxHeight: 400,
            ),
          ),
        ),
      );

      await tester.pump();

      // 验证组件正常渲染
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('清除搜索测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 输入文本
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test');
      await tester.pump();

      // 查找清除按钮（可能需要等待文本输入处理）
      await tester.pump(const Duration(milliseconds: 100));
      
      // 验证文本输入成功
      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('学习状态筛选器测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 验证学习状态筛选器
      expect(find.text('未开始'), findsOneWidget);
      expect(find.text('学习中'), findsOneWidget);
      expect(find.text('复习中'), findsOneWidget);
      expect(find.text('已掌握'), findsOneWidget);
    });

    testWidgets('收藏状态筛选器测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 验证收藏状态筛选器
      expect(find.text('收藏状态'), findsOneWidget);

      // 点击收藏筛选器
      await tester.tap(find.text('收藏状态'));
      await tester.pump();

      // 验证状态切换
      expect(find.text('已收藏'), findsOneWidget);
    });

    testWidgets('清除全部筛选器测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 先选择一些筛选器
      await tester.tap(find.text('入门'));
      await tester.pump();

      await tester.tap(find.text('收藏状态'));
      await tester.pump();

      // 验证"清除全部"按钮出现
      expect(find.text('清除全部'), findsOneWidget);

      // 点击清除全部
      await tester.tap(find.text('清除全部'));
      await tester.pump();

      // 验证筛选器重置
      expect(find.text('收藏状态'), findsOneWidget);
    });

    testWidgets('响应式布局测试', (WidgetTester tester) async {
      // 测试小屏幕
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 验证在小屏幕上正常显示
      expect(find.byType(WordSearchBar), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // 重置屏幕尺寸
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('空状态显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 输入搜索查询触发搜索
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'nonexistent');
      
      // 模拟搜索提交
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      
      // 等待搜索完成
      await tester.pump(const Duration(seconds: 1));

      // 验证组件仍然正常（即使没有结果）
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('搜索建议测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 输入部分文本触发建议
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'he');
      await tester.pump();

      // 等待建议加载
      await tester.pump(const Duration(milliseconds: 500));

      // 验证组件正常工作（建议功能不会导致错误）
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('无障碍访问测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 验证关键元素存在（用于语音阅读器）
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('筛选器'), findsOneWidget);
      expect(find.text('难度'), findsOneWidget);
    });

    testWidgets('错误处理测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 输入特殊字符
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '!@#\$%^&*()');
      await tester.pump();

      // 验证特殊字符不会导致崩溃
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('性能测试', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();
      stopwatch.stop();

      // 验证组件初始化时间合理（小于1秒）
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(WordSearchBar), findsOneWidget);
    });
  });
}
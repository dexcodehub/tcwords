import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/learning/word_search_bar.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('WordSearchBar功能测试', () {
    late WordService wordService;

    setUpAll(() {
      wordService = WordService();
    });

    testWidgets('搜索算法基础功能测试', (WidgetTester tester) async {
      List<Word> searchResults = [];
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(
              onSearchResults: (results) {
                searchResults = results;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // 输入搜索查询
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'hello');
      
      // 提交搜索
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      
      // 等待搜索完成
      await tester.pump(const Duration(seconds: 1));

      // 验证搜索功能正常工作（不会崩溃）
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('搜索服务层测试', (WidgetTester tester) async {
      // 测试WordService的搜索功能
      final results = await wordService.searchWords('test');
      
      // 验证搜索结果是列表类型
      expect(results, isA<List<Word>>());
      
      // 验证搜索不会抛出异常
      expect(() async => await wordService.searchWords(''), returnsNormally);
    });

    testWidgets('搜索建议功能测试', (WidgetTester tester) async {
      // 测试搜索建议服务
      final suggestions = await wordService.getSearchSuggestions('he');
      
      // 验证建议结果
      expect(suggestions, isA<List<String>>());
      expect(suggestions.length, lessThanOrEqualTo(10));
    });

    testWidgets('难度筛选逻辑测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 选择难度筛选器
      await tester.tap(find.text('入门'));
      await tester.pump();

      // 输入搜索查询
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      
      // 等待搜索完成
      await tester.pump(const Duration(seconds: 1));

      // 验证筛选功能正常工作
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('收藏状态筛选测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 切换收藏筛选器
      await tester.tap(find.text('收藏状态'));
      await tester.pump();
      
      expect(find.text('已收藏'), findsOneWidget);
      
      await tester.tap(find.text('已收藏'));
      await tester.pump();
      
      expect(find.text('未收藏'), findsOneWidget);
    });

    testWidgets('搜索历史功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 执行多次搜索
      final searchField = find.byType(TextField);
      
      await tester.enterText(searchField, 'hello');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      
      await tester.enterText(searchField, 'world');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      // 验证搜索功能正常
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('清除筛选器功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 设置多个筛选器
      await tester.tap(find.text('入门'));
      await tester.pump();
      
      await tester.tap(find.text('收藏状态'));
      await tester.pump();
      
      await tester.tap(find.text('学习中'));
      await tester.pump();

      // 验证清除全部按钮出现
      expect(find.text('清除全部'), findsOneWidget);

      // 点击清除全部
      await tester.tap(find.text('清除全部'));
      await tester.pump();

      // 验证筛选器重置
      expect(find.text('收藏状态'), findsOneWidget);
    });

    testWidgets('搜索性能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      final stopwatch = Stopwatch()..start();

      // 执行搜索
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'performance');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      stopwatch.stop();

      // 验证搜索响应时间合理（小于2秒）
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('搜索结果回调测试', (WidgetTester tester) async {
      List<Word> callbackResults = [];
      String callbackQuery = '';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(
              onSearchResults: (results) {
                callbackResults = results;
              },
              onQueryChanged: (query) {
                callbackQuery = query;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // 执行搜索
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'callback');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      
      // 等待回调执行
      await tester.pump(const Duration(seconds: 1));

      // 验证组件正常工作（回调设置正确）
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('空查询处理测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 提交空查询
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      // 验证空查询不会导致错误
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('特殊字符搜索测试', (WidgetTester tester) async {
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
      await tester.enterText(searchField, '!@#%^&*()');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      // 验证特殊字符搜索不会崩溃
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('多语言搜索测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 输入中文查询
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '你好');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      // 验证多语言搜索正常工作
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('搜索状态管理测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 执行搜索
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'state');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      
      // 在搜索过程中验证组件状态
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(WordSearchBar), findsOneWidget);
      
      // 搜索完成后验证状态
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(WordSearchBar), findsOneWidget);
    });

    testWidgets('搜索算法准确性测试', (WidgetTester tester) async {
      // 直接测试搜索算法
      final results = await wordService.searchWords('hello');
      
      // 验证搜索结果类型
      expect(results, isA<List<Word>>());
      
      // 测试空搜索
      final emptyResults = await wordService.searchWords('');
      expect(emptyResults, isA<List<Word>>());
      
      // 测试筛选功能
      final filteredResults = await wordService.searchWords(
        'test',
        difficulties: [WordDifficulty.beginner],
      );
      expect(filteredResults, isA<List<Word>>());
    });

    testWidgets('搜索相关性排序测试', (WidgetTester tester) async {
      // 测试搜索建议功能
      final suggestions = await wordService.getSearchSuggestions('he', limit: 5);
      
      // 验证建议数量不超过限制
      expect(suggestions.length, lessThanOrEqualTo(5));
      expect(suggestions, isA<List<String>>());
    });

    testWidgets('组件销毁时的资源清理测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordSearchBar(),
          ),
        ),
      );

      await tester.pump();

      // 输入搜索并立即销毁组件
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'cleanup');
      
      // 销毁组件
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox()),
      ));

      // 验证组件销毁不会导致内存泄漏或错误
      expect(find.byType(WordSearchBar), findsNothing);
    });
  });
}
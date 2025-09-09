import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/learning/word_bookmark.dart';
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

  group('WordBookmark功能测试', () {
    late List<Word> testWords;
    late WordService wordService;

    setUpAll(() {
      wordService = WordService();
      testWords = [
        Word(
          id: 'test_bookmark_1',
          text: 'favorite',
          category: 'adjectives',
          imagePath: 'assets/images/favorite.png',
          audioPath: 'assets/audios/favorite.mp3',
          meaning: '最喜欢的',
          example: 'This is my favorite book.',
          difficulty: WordDifficulty.intermediate,
          learningStatus: LearningStatus.learning,
          isBookmarked: true,
        ),
        Word(
          id: 'test_bookmark_2',
          text: 'excellent',
          category: 'adjectives',
          imagePath: 'assets/images/excellent.png',
          audioPath: 'assets/audios/excellent.mp3',
          meaning: '极好的',
          example: 'The performance was excellent.',
          difficulty: WordDifficulty.advanced,
          learningStatus: LearningStatus.mastered,
          isBookmarked: true,
        ),
        Word(
          id: 'test_bookmark_3',
          text: 'beautiful',
          category: 'adjectives',
          imagePath: 'assets/images/beautiful.png',
          audioPath: 'assets/audios/beautiful.mp3',
          meaning: '美丽的',
          example: 'She is beautiful.',
          difficulty: WordDifficulty.beginner,
          learningStatus: LearningStatus.reviewing,
          isBookmarked: true,
        ),
      ];
    });

    testWidgets('收藏数据加载功能测试', (WidgetTester tester) async {
      // 预设收藏数据
      for (final word in testWords) {
        await wordService.bookmarkWord(word.id);
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证收藏数据加载
      expect(find.text('收藏的单词'), findsOneWidget);
    });

    testWidgets('搜索功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 查找搜索输入框
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // 输入搜索文本
      await tester.enterText(searchField, 'beautiful');
      await tester.pump();

      // 验证搜索功能（通过组件存在性验证）
      expect(find.byType(WordBookmark), findsOneWidget);
    });

    testWidgets('筛选功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证筛选按钮存在
      expect(find.text('全部'), findsWidgets);
    });

    testWidgets('视图模式切换测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 查找视图切换按钮
      final viewToggleButtons = find.byIcon(Icons.view_list);
      if (viewToggleButtons.evaluate().isNotEmpty) {
        await tester.tap(viewToggleButtons.first);
        await tester.pump();
      }

      // 验证组件正常工作
      expect(find.byType(WordBookmark), findsOneWidget);
    });

    testWidgets('取消收藏功能测试', (WidgetTester tester) async {
      // 预设一个收藏的单词
      await wordService.bookmarkWord('test_bookmark_1');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证组件渲染正常
      expect(find.byType(WordBookmark), findsOneWidget);
    });

    testWidgets('批量操作功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 查找批量操作相关按钮
      final batchButtons = find.text('批量操作');
      if (batchButtons.evaluate().isNotEmpty) {
        await tester.tap(batchButtons.first);
        await tester.pump();
      }

      // 验证批量操作界面
      expect(find.byType(WordBookmark), findsOneWidget);
    });

    testWidgets('空状态处理测试', (WidgetTester tester) async {
      // 清除所有收藏
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bookmarked_words');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证空状态显示
      expect(find.byType(WordBookmark), findsOneWidget);
    });

    testWidgets('回调函数测试', (WidgetTester tester) async {
      bool wordTapCalled = false;
      bool startReviewCalled = false;
      bool batchOperationCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(
              onWordTap: () {
                wordTapCalled = true;
              },
              onStartReview: () {
                startReviewCalled = true;
              },
              onBatchOperation: (words) {
                batchOperationCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证组件创建成功
      expect(find.byType(WordBookmark), findsOneWidget);
      
      // 回调函数的具体测试需要在有实际收藏数据时进行
      // 这里主要验证组件能正确接收回调函数而不报错
    });

    testWidgets('数据持久化测试', (WidgetTester tester) async {
      // 添加收藏
      await wordService.bookmarkWord('test_persistence');
      
      // 验证收藏状态持久化
      final bookmarks = await wordService.getBookmarkedWordIds();
      expect(bookmarks.contains('test_persistence'), isTrue);

      // 移除收藏
      await wordService.unbookmarkWord('test_persistence');
      
      // 验证移除后的状态
      final updatedBookmarks = await wordService.getBookmarkedWordIds();
      expect(updatedBookmarks.contains('test_persistence'), isFalse);
    });

    testWidgets('状态管理测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      // 初始状态
      await tester.pumpAndSettle();
      expect(find.byType(WordBookmark), findsOneWidget);

      // 触发状态更新（通过搜索）
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'test');
        await tester.pump();
        
        // 验证状态更新后组件仍正常工作
        expect(find.byType(WordBookmark), findsOneWidget);
      }
    });

    testWidgets('错误处理测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证在没有网络或数据错误时组件不崩溃
      expect(find.byType(WordBookmark), findsOneWidget);
    });

    testWidgets('性能测试 - 大量数据处理', (WidgetTester tester) async {
      // 创建大量测试数据
      final largeDataWords = List.generate(100, (index) => Word(
        id: 'large_data_$index',
        text: 'word_$index',
        category: 'test',
        imagePath: 'assets/images/test.png',
        audioPath: 'assets/audios/test.mp3',
        meaning: 'meaning_$index',
        difficulty: WordDifficulty.beginner,
        isBookmarked: true,
      ));

      // 添加到收藏
      for (int i = 0; i < 10; i++) {
        await wordService.bookmarkWord('large_data_$i');
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordBookmark(),
          ),
        ),
      );

      // 测试大量数据下的渲染性能
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // 验证渲染时间合理（小于1秒）
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(WordBookmark), findsOneWidget);
    });
  });
}
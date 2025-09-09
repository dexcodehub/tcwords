import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/learning/word_card.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  // 初始化Flutter绑定
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('WordCard UI测试', () {
    testWidgets('WordCard基础渲染测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'test_1',
        text: 'hello',
        category: 'greetings',
        imagePath: 'assets/images/hello.png',
        audioPath: 'assets/audios/hello.mp3',
        meaning: '你好',
        example: 'Hello, world!',
        difficulty: WordDifficulty.beginner,
        learningStatus: LearningStatus.notStarted,
        isBookmarked: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: testWord),
          ),
        ),
      );

      // 验证正面显示
      expect(find.text('hello'), findsOneWidget);
      expect(find.text('GREETINGS'), findsOneWidget);
      expect(find.text('点击卡片查看含义'), findsOneWidget);
      expect(find.text('发音'), findsOneWidget);
      
      // 验证状态显示
      expect(find.text('未开始'), findsOneWidget);
      
      // 验证收藏按钮
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('WordCard翻转功能测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'test_2',
        text: 'beautiful',
        category: 'adjectives',
        imagePath: 'assets/images/beautiful.png',
        audioPath: 'assets/audios/beautiful.mp3',
        meaning: '美丽的',
        example: 'She is beautiful.',
        difficulty: WordDifficulty.intermediate,
        learningStatus: LearningStatus.learning,
        isBookmarked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: testWord),
          ),
        ),
      );

      // 验证初始状态（正面）
      expect(find.text('beautiful'), findsOneWidget);
      expect(find.text('点击卡片查看含义'), findsOneWidget);

      // 点击卡片翻转
      await tester.tap(find.byType(WordCard));
      await tester.pump(); // 开始动画
      await tester.pump(const Duration(milliseconds: 700)); // 等待动画完成

      // 验证翻转后状态（背面）- 使用更灵活的查找
      expect(find.textContaining('美丽的'), findsOneWidget);
      expect(find.textContaining('She is beautiful'), findsOneWidget);
    });

    testWidgets('WordCard预设翻转状态测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'test_3',
        text: 'complex',
        category: 'adjectives',
        imagePath: 'assets/images/complex.png',
        audioPath: 'assets/audios/complex.mp3',
        meaning: '复杂的',
        example: 'This is a complex problem.',
        difficulty: WordDifficulty.advanced,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              showAnswer: true, // 预设为显示答案
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 应该直接显示背面
      expect(find.text('复杂的'), findsOneWidget);
      expect(find.text('This is a complex problem.'), findsOneWidget);
    });

    testWidgets('WordCard不同难度级别颜色测试', (WidgetTester tester) async {
      final beginnerWord = Word(
        id: 'beginner_test',
        text: 'cat',
        category: 'animals',
        imagePath: 'assets/images/cat.png',
        audioPath: 'assets/audios/cat.mp3',
        difficulty: WordDifficulty.beginner,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: beginnerWord),
          ),
        ),
      );

      // 验证入门级别的颜色应用
      expect(find.text('入门'), findsOneWidget);
      
      // 检查Container装饰
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('cat'),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('WordCard学习状态颜色测试', (WidgetTester tester) async {
      final masteredWord = Word(
        id: 'mastered_test',
        text: 'excellent',
        category: 'adjectives',
        imagePath: 'assets/images/excellent.png',
        audioPath: 'assets/audios/excellent.mp3',
        learningStatus: LearningStatus.mastered,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: masteredWord),
          ),
        ),
      );

      // 验证已掌握状态显示
      expect(find.text('已掌握'), findsOneWidget);
    });

    testWidgets('WordCard收藏状态显示测试', (WidgetTester tester) async {
      final bookmarkedWord = Word(
        id: 'bookmarked_test',
        text: 'favorite',
        category: 'adjectives',
        imagePath: 'assets/images/favorite.png',
        audioPath: 'assets/audios/favorite.mp3',
        isBookmarked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: bookmarkedWord),
          ),
        ),
      );

      // 验证收藏状态显示
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
    });

    testWidgets('WordCard非互动模式测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'non_interactive_test',
        text: 'readonly',
        category: 'test',
        imagePath: 'assets/images/readonly.png',
        audioPath: 'assets/audios/readonly.mp3',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              isInteractive: false,
            ),
          ),
        ),
      );

      // 在非互动模式下，收藏按钮不应该显示
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
    });

    testWidgets('WordCard长文本布局测试', (WidgetTester tester) async {
      final longTextWord = Word(
        id: 'long_text_test',
        text: 'supercalifragilisticexpialidocious',
        category: 'fun',
        imagePath: 'assets/images/long.png',
        audioPath: 'assets/audios/long.mp3',
        meaning: '这是一个非常长的单词，用来测试UI组件的文本处理能力和布局是否会出现溢出问题，需要确保文本足够长以测试换行和布局适应性',
        example: 'Supercalifragilisticexpialidocious is a very long word that was used in the movie Mary Poppins to demonstrate extraordinary linguistic capabilities.',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: longTextWord),
          ),
        ),
      );

      // 验证长文本正常显示，无溢出
      expect(find.text('supercalifragilisticexpialidocious'), findsOneWidget);
      
      // 翻转查看背面长文本
      await tester.tap(find.byType(WordCard));
      await tester.pumpAndSettle(const Duration(milliseconds: 700));

      expect(find.textContaining('这是一个非常长的单词'), findsOneWidget);
      expect(find.textContaining('Supercalifragilisticexpialidocious is a very long word'), findsOneWidget);
    });

    testWidgets('WordCard空内容处理测试', (WidgetTester tester) async {
      final minimalWord = Word(
        id: 'minimal_test',
        text: 'test',
        category: 'test',
        imagePath: 'assets/images/test.png',
        audioPath: 'assets/audios/test.mp3',
        // meaning和example为null
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: minimalWord),
          ),
        ),
      );

      // 翻转到背面
      await tester.tap(find.byType(WordCard));
      await tester.pumpAndSettle(const Duration(milliseconds: 700));

      // 验证空内容时不会导致错误
      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('WordCard响应式布局测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'responsive_test',
        text: 'responsive',
        category: 'tech',
        imagePath: 'assets/images/responsive.png',
        audioPath: 'assets/audios/responsive.mp3',
        meaning: '响应式的',
      );

      // 测试小屏幕
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: testWord),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证在小屏幕上正常显示
      expect(find.text('responsive'), findsOneWidget);

      // 测试大屏幕
      tester.binding.window.physicalSizeTestValue = const Size(414, 896);
      await tester.pump();

      // 验证在大屏幕上也正常显示
      expect(find.text('responsive'), findsOneWidget);

      // 重置屏幕尺寸
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('WordCard自定义尺寸测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'custom_size_test',
        text: 'custom',
        category: 'test',
        imagePath: 'assets/images/custom.png',
        audioPath: 'assets/audios/custom.mp3',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              width: 300,
              height: 400,
            ),
          ),
        ),
      );

      // 验证自定义尺寸的WordCard能正常渲染
      expect(find.byType(WordCard), findsOneWidget);
      expect(find.text('custom'), findsOneWidget);
      
      // 验证组件内容正常显示（不检查具体尺寸）
      expect(find.text('点击卡片查看含义'), findsOneWidget);
    });

    testWidgets('WordCard动画测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'animation_test',
        text: 'animate',
        category: 'verbs',
        imagePath: 'assets/images/animate.png',
        audioPath: 'assets/audios/animate.mp3',
        meaning: '使生动',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: testWord),
          ),
        ),
      );

      // 验证初始状态
      expect(find.text('animate'), findsOneWidget);
      
      // 点击卡片开始翻转
      await tester.tap(find.byType(WordCard));
      await tester.pump();
      
      // 简单验证不报错即可
      expect(find.byType(WordCard), findsOneWidget);
    });

    testWidgets('WordCard无障碍访问测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'accessibility_test',
        text: 'accessible',
        category: 'adjectives',
        imagePath: 'assets/images/accessible.png',
        audioPath: 'assets/audios/accessible.mp3',
        meaning: '可访问的',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: testWord),
          ),
        ),
      );

      // 验证关键元素存在（用于语音阅读器）
      expect(find.text('accessible'), findsOneWidget);
      expect(find.text('发音'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    group('WordCard错误处理测试', () {
      testWidgets('空单词文本处理', (WidgetTester tester) async {
        final emptyTextWord = Word(
          id: 'empty_test',
          text: '', // 空文本
          category: 'test',
          imagePath: 'assets/images/empty.png',
          audioPath: 'assets/audios/empty.mp3',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: WordCard(word: emptyTextWord),
            ),
          ),
        );

        // 应该能正常渲染而不报错
        expect(find.byType(WordCard), findsOneWidget);
      });

      testWidgets('特殊字符处理', (WidgetTester tester) async {
        final specialCharWord = Word(
          id: 'special_char_test',
          text: 'café & résumé',
          category: 'international',
          imagePath: 'assets/images/special.png',
          audioPath: 'assets/audios/special.mp3',
          meaning: '咖啡馆和简历 ✨ 🌟',
          example: 'Let\'s go to the café and discuss your résumé.',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: WordCard(word: specialCharWord),
            ),
          ),
        );

        // 验证特殊字符正常显示
        expect(find.text('café & résumé'), findsOneWidget);
        
        // 翻转查看含义中的特殊字符
        await tester.tap(find.byType(WordCard));
        await tester.pumpAndSettle(const Duration(milliseconds: 700));
        
        expect(find.textContaining('咖啡馆和简历 ✨ 🌟'), findsOneWidget);
      });
    });
  });
}
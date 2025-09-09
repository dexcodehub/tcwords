import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/learning/word_card.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  // 初始化Flutter绑定
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('WordCard功能逻辑测试', () {
    testWidgets('WordCard翻转回调测试', (WidgetTester tester) async {
      bool flipCallbackTriggered = false;
      
      final testWord = Word(
        id: 'flip_test',
        text: 'test',
        category: 'test',
        imagePath: 'assets/images/test.png',
        audioPath: 'assets/audios/test.mp3',
        meaning: '测试',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              onFlip: () {
                flipCallbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // 点击卡片触发翻转
      await tester.tap(find.byType(WordCard));
      await tester.pump();

      // 验证回调被触发
      expect(flipCallbackTriggered, isTrue);
    });

    testWidgets('WordCard收藏切换功能测试', (WidgetTester tester) async {
      bool bookmarkCallbackTriggered = false;
      
      final testWord = Word(
        id: 'bookmark_test',
        text: 'bookmark',
        category: 'test',
        imagePath: 'assets/images/bookmark.png',
        audioPath: 'assets/audios/bookmark.mp3',
        isBookmarked: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              onBookmarkToggle: () {
                bookmarkCallbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // 查找收藏按钮并点击
      final bookmarkButton = find.byIcon(Icons.bookmark_border);
      expect(bookmarkButton, findsOneWidget);
      
      await tester.tap(bookmarkButton);
      await tester.pump();

      // 验证回调被触发
      expect(bookmarkCallbackTriggered, isTrue);
    });

    testWidgets('WordCard学习状态更新功能测试', (WidgetTester tester) async {
      bool statusCallbackTriggered = false;
      
      final testWord = Word(
        id: 'status_test',
        text: 'status',
        category: 'test',
        imagePath: 'assets/images/status.png',
        audioPath: 'assets/audios/status.mp3',
        meaning: '状态',
        learningStatus: LearningStatus.notStarted,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              onStatusUpdate: () {
                statusCallbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // 翻转到背面查看学习状态按钮
      await tester.tap(find.byType(WordCard));
      await tester.pumpAndSettle();

      // 查找"继续学习"按钮并点击
      final learningButton = find.text('继续学习');
      expect(learningButton, findsOneWidget);
      
      await tester.tap(learningButton);
      await tester.pump();

      // 验证回调被触发
      expect(statusCallbackTriggered, isTrue);
    });

    testWidgets('WordCard发音按钮交互测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'speak_test',
        text: 'speak',
        category: 'verbs',
        imagePath: 'assets/images/speak.png',
        audioPath: 'assets/audios/speak.mp3',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: testWord),
          ),
        ),
      );

      // 查找发音按钮
      final speakButton = find.text('发音');
      expect(speakButton, findsOneWidget);
      
      // 点击发音按钮
      await tester.tap(speakButton);
      await tester.pump();

      // 由于TTS服务在测试环境中可能不可用，主要验证按钮可点击
      expect(find.byType(WordCard), findsOneWidget);
    });

    testWidgets('WordCard非互动模式功能验证', (WidgetTester tester) async {
      bool flipCallbackTriggered = false;
      bool bookmarkCallbackTriggered = false;
      
      final testWord = Word(
        id: 'non_interactive_test',
        text: 'readonly',
        category: 'test',
        imagePath: 'assets/images/readonly.png',
        audioPath: 'assets/audios/readonly.mp3',
        meaning: '只读',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              isInteractive: false,
              onFlip: () {
                flipCallbackTriggered = true;
              },
              onBookmarkToggle: () {
                bookmarkCallbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // 在非互动模式下，点击卡片不应该触发翻转
      await tester.tap(find.byType(WordCard));
      await tester.pump();

      expect(flipCallbackTriggered, isFalse);

      // 收藏按钮在非互动模式下不应该显示
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
      expect(find.byIcon(Icons.bookmark), findsNothing);
    });

    testWidgets('WordCard动画状态管理测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'animation_state_test',
        text: 'animate',
        category: 'verbs',
        imagePath: 'assets/images/animate.png',
        audioPath: 'assets/audios/animate.mp3',
        meaning: '动画',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(word: testWord),
          ),
        ),
      );

      // 初始状态验证
      expect(find.text('animate'), findsOneWidget);
      expect(find.text('点击卡片查看含义'), findsOneWidget);

      // 开始翻转动画
      await tester.tap(find.byType(WordCard));
      await tester.pump(); // 开始动画
      
      // 等待动画进行中
      await tester.pump(const Duration(milliseconds: 300));
      
      // 完成动画
      await tester.pumpAndSettle();

      // 验证翻转后状态
      expect(find.text('动画'), findsOneWidget);
      expect(find.text('再次点击返回正面'), findsOneWidget);
    });

    testWidgets('WordCard预设显示答案状态测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'preset_answer_test',
        text: 'preset',
        category: 'adjectives',
        imagePath: 'assets/images/preset.png',
        audioPath: 'assets/audios/preset.mp3',
        meaning: '预设的',
        example: 'This is a preset value.',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              showAnswer: true, // 预设显示答案
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 应该直接显示背面内容
      expect(find.text('预设的'), findsOneWidget);
      expect(find.text('This is a preset value.'), findsOneWidget);
    });

    testWidgets('WordCard学习状态按钮逻辑测试', (WidgetTester tester) async {
      int statusUpdateCount = 0;
      
      final testWord = Word(
        id: 'status_buttons_test',
        text: 'progress',
        category: 'nouns',
        imagePath: 'assets/images/progress.png',
        audioPath: 'assets/audios/progress.mp3',
        meaning: '进度',
        learningStatus: LearningStatus.notStarted,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              onStatusUpdate: () {
                statusUpdateCount++;
              },
            ),
          ),
        ),
      );

      // 翻转到背面
      await tester.tap(find.byType(WordCard));
      await tester.pumpAndSettle();

      // 测试不同状态按钮
      await tester.tap(find.text('继续学习'));
      await tester.pump();
      expect(statusUpdateCount, equals(1));

      await tester.tap(find.text('需要复习'));
      await tester.pump();
      expect(statusUpdateCount, equals(2));

      await tester.tap(find.text('已掌握'));
      await tester.pump();
      expect(statusUpdateCount, equals(3));
    });

    testWidgets('WordCard自定义尺寸功能测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'custom_size_function_test',
        text: 'custom',
        category: 'adjectives',
        imagePath: 'assets/images/custom.png',
        audioPath: 'assets/audios/custom.mp3',
        meaning: '自定义的',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WordCard(
              word: testWord,
              width: 250,
              height: 350,
            ),
          ),
        ),
      );

      // 验证自定义尺寸的卡片功能正常
      expect(find.text('custom'), findsOneWidget);
      
      // 测试翻转功能
      await tester.tap(find.byType(WordCard));
      await tester.pumpAndSettle();
      
      expect(find.text('自定义的'), findsOneWidget);
    });

    group('WordCard错误处理和边界情况', () {
      testWidgets('空内容字段处理', (WidgetTester tester) async {
        final emptyContentWord = Word(
          id: 'empty_content_test',
          text: 'empty',
          category: 'test',
          imagePath: 'assets/images/empty.png',
          audioPath: 'assets/audios/empty.mp3',
          // meaning和example为null
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: WordCard(word: emptyContentWord),
            ),
          ),
        );

        // 翻转到背面，应该能正常处理空内容
        await tester.tap(find.byType(WordCard));
        await tester.pumpAndSettle();

        // 验证不会因为空内容而崩溃
        expect(find.byType(WordCard), findsOneWidget);
        expect(find.text('empty'), findsOneWidget);
      });

      testWidgets('极长文本处理', (WidgetTester tester) async {
        final longTextWord = Word(
          id: 'long_text_function_test',
          text: 'pneumonoultramicroscopicsilicovolcanoconiosislongwordtest',
          category: 'medical',
          imagePath: 'assets/images/long.png',
          audioPath: 'assets/audios/long.mp3',
          meaning: '这是一个极其长的医学术语，用来描述由吸入极细的硅酸盐粉尘引起的肺部疾病，通常在火山环境中发现，这个定义本身也非常长，用来测试文本布局和处理能力',
          example: 'Pneumonoultramicroscopicsilicovolcanoconiosislongwordtest is a very long medical term that was created to demonstrate the handling of extremely long words and text content in user interface components.',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: WordCard(word: longTextWord),
            ),
          ),
        );

        // 验证长文本在正面正常显示
        expect(find.byType(WordCard), findsOneWidget);
        
        // 翻转查看背面长文本
        await tester.tap(find.byType(WordCard));
        await tester.pumpAndSettle();

        // 验证背面长文本也能正常处理
        expect(find.textContaining('这是一个极其长的医学术语'), findsOneWidget);
        expect(find.textContaining('Pneumonoultramicroscopicsilicovolcanoconiosislongwordtest is a very long'), findsOneWidget);
      });

      testWidgets('特殊字符和表情符号处理', (WidgetTester tester) async {
        final specialCharWord = Word(
          id: 'special_char_function_test',
          text: 'émojis & spéciàl',
          category: 'unicode',
          imagePath: 'assets/images/special.png',
          audioPath: 'assets/audios/special.mp3',
          meaning: '表情符号和特殊字符 😀 🎉 ✨ 🌟 💖',
          example: 'Unicode characters like café, résumé, and émojis 🚀 are supported!',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: WordCard(word: specialCharWord),
            ),
          ),
        );

        // 验证特殊字符在正面正常显示
        expect(find.text('émojis & spéciàl'), findsOneWidget);
        
        // 翻转查看背面的表情符号和特殊字符
        await tester.tap(find.byType(WordCard));
        await tester.pumpAndSettle();

        expect(find.textContaining('😀 🎉 ✨ 🌟 💖'), findsOneWidget);
        expect(find.textContaining('🚀'), findsOneWidget);
      });
    });

    testWidgets('WordCard状态持久化验证', (WidgetTester tester) async {
      final testWord = Word(
        id: 'persistence_test',
        text: 'persist',
        category: 'verbs',
        imagePath: 'assets/images/persist.png',
        audioPath: 'assets/audios/persist.mp3',
        meaning: '坚持',
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

      // 验证初始状态正确显示
      expect(find.text('学习中'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);

      // 进行交互操作
      await tester.tap(find.byType(WordCard)); // 翻转
      await tester.pumpAndSettle();

      // 验证背面状态也正确显示
      expect(find.text('persist'), findsOneWidget);
      expect(find.text('坚持'), findsOneWidget);
    });
  });
}
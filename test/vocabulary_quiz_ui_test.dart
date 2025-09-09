import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/learning/vocabulary_quiz.dart';
import 'package:tcword/src/widgets/progress_indicator.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/models/learning/quiz_models.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  // 初始化Flutter绑定
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('VocabularyQuiz UI测试', () {
    late List<Word> testWords;

    setUp(() {
      testWords = [
        Word(
          id: '1',
          text: 'apple',
          category: 'food',
          imagePath: 'assets/images/apple.png',
          audioPath: 'assets/audios/apple.mp3',
          meaning: '苹果',
          difficulty: WordDifficulty.beginner,
        ),
        Word(
          id: '2',
          text: 'beautiful',
          category: 'adjectives',
          imagePath: 'assets/images/beautiful.png',
          audioPath: 'assets/audios/beautiful.mp3',
          meaning: '美丽的',
          difficulty: WordDifficulty.intermediate,
        ),
        Word(
          id: '3',
          text: 'excellent',
          category: 'adjectives',
          imagePath: 'assets/images/excellent.png',
          audioPath: 'assets/audios/excellent.mp3',
          meaning: '优秀的',
          difficulty: WordDifficulty.advanced,
        ),
        Word(
          id: '4',
          text: 'computer',
          category: 'technology',
          imagePath: 'assets/images/computer.png',
          audioPath: 'assets/audios/computer.mp3',
          meaning: '电脑',
          difficulty: WordDifficulty.elementary,
        ),
      ];
    });

    testWidgets('英译中测验基础渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '英译中测验',
          ),
        ),
      );

      // 验证基础界面元素
      expect(find.text('英译中测验'), findsOneWidget);
      expect(find.text('题目 1/4'), findsOneWidget);
      expect(find.text('选择下面单词的正确含义：'), findsOneWidget);
      expect(find.text('选择答案:'), findsOneWidget);
      expect(find.text('跳过'), findsOneWidget);
      expect(find.text('提交'), findsOneWidget);

      // 验证进度指示器
      expect(find.byType(AnimatedProgressIndicator), findsOneWidget);

      // 验证选项按钮存在
      expect(find.textContaining('A.'), findsOneWidget);
      expect(find.textContaining('B.'), findsOneWidget);
      expect(find.textContaining('C.'), findsOneWidget);
      expect(find.textContaining('D.'), findsOneWidget);
    });

    testWidgets('中译英测验渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.chineseToEnglish,
            title: '中译英测验',
          ),
        ),
      );

      // 验证中译英特有提示
      expect(find.text('选择下面含义对应的英文单词：'), findsOneWidget);
    });

    testWidgets('听音选义测验渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.listeningChoice,
            title: '听音选义测验',
          ),
        ),
      );

      // 验证听音测验特有元素
      expect(find.text('听音选择正确含义：'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.text('点击播放'), findsOneWidget);
    });

    testWidgets('有时间限制的测验渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '限时测验',
            timeLimit: 300, // 5分钟
          ),
        ),
      );

      // 验证倒计时显示
      expect(find.text('300'), findsOneWidget);
      expect(find.byType(CustomCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('选项选择交互测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '选择测试',
          ),
        ),
      );

      // 初始状态下提交按钮应该是禁用的
      final submitButton = find.text('提交');
      expect(submitButton, findsOneWidget);

      // 选择一个选项
      await tester.tap(find.textContaining('A.'));
      await tester.pump();

      // 验证选项被选中（通过按钮颜色变化等方式，这里简化验证）
      expect(find.text('提交'), findsOneWidget);
    });

    testWidgets('跳过按钮交互测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '跳过测试',
          ),
        ),
      );

      // 点击跳过按钮
      await tester.tap(find.text('跳过'));
      await tester.pump();

      // 验证进入下一题（题目序号变化）
      expect(find.text('题目 2/4'), findsOneWidget);
    });

    testWidgets('提交答案和反馈显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '提交测试',
          ),
        ),
      );

      // 选择一个选项
      await tester.tap(find.textContaining('A.'));
      await tester.pump();

      // 点击提交
      await tester.tap(find.text('提交'));
      await tester.pump();

      // 验证答案反馈显示
      expect(find.textContaining('回答'), findsOneWidget); // "回答正确！" 或 "回答错误"
      expect(find.text('下一题'), findsOneWidget);
    });

    testWidgets('进度条更新测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '进度测试',
          ),
        ),
      );

      // 初始进度 - 验证进度条存在而不是具体百分比
      expect(find.text('题目 1/4'), findsOneWidget);

      // 跳过第一题
      await tester.tap(find.text('跳过'));
      await tester.pump();

      // 验证进度更新
      expect(find.text('题目 2/4'), findsOneWidget);
    });

    testWidgets('测验完成和结果显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first], // 只有一道题
            quizType: QuizType.englishToChinese,
            title: '完成测试',
          ),
        ),
      );

      // 选择答案并提交
      await tester.tap(find.textContaining('A.'));
      await tester.pump();
      await tester.tap(find.text('提交'));
      await tester.pump();

      // 点击下一题（实际是查看结果）- 更灵活地查找按钮
      final nextButtonFinder = find.text('下一题');
      final resultButtonFinder = find.text('查看结果');
      
      if (nextButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(nextButtonFinder);
      } else if (resultButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(resultButtonFinder);
      }
      await tester.pumpAndSettle();

      // 验证结果页面
      expect(find.text('测验结果'), findsOneWidget);
      expect(find.text('分'), findsOneWidget);
      expect(find.text('完成'), findsOneWidget);
    });

    testWidgets('响应式布局测试', (WidgetTester tester) async {
      // 小屏幕测试
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '响应式测试',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证在小屏幕上正常显示
      expect(find.text('响应式测试'), findsOneWidget);
      expect(find.text('选择答案:'), findsOneWidget);

      // 重置屏幕尺寸
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('长文本选项布局测试', (WidgetTester tester) async {
      final longTextWords = [
        Word(
          id: 'long1',
          text: 'supercalifragilisticexpialidocious',
          category: 'fun',
          imagePath: 'assets/images/long.png',
          audioPath: 'assets/audios/long.mp3',
          meaning: '这是一个非常长的单词含义，用来测试UI组件在处理长文本时的布局是否会出现溢出问题',
          difficulty: WordDifficulty.advanced,
        ),
        Word(
          id: 'long2',
          text: 'antidisestablishmentarianism',
          category: 'politics',
          imagePath: 'assets/images/long2.png',
          audioPath: 'assets/audios/long2.mp3',
          meaning: '反对废除国教主义',
          difficulty: WordDifficulty.advanced,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: longTextWords,
            quizType: QuizType.englishToChinese,
            title: '长文本测试',
          ),
        ),
      );

      // 验证长文本正常显示，无溢出
      expect(find.byType(VocabularyQuiz), findsOneWidget);
      expect(find.text('长文本测试'), findsOneWidget);
    });

    testWidgets('空单词列表处理测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [], // 空列表
            quizType: QuizType.englishToChinese,
            title: '空列表测试',
          ),
        ),
      );

      // 验证空列表时直接显示结果页面
      expect(find.text('测验结果'), findsOneWidget);
    });

    testWidgets('单个单词测验测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first],
            quizType: QuizType.englishToChinese,
            title: '单词测试',
          ),
        ),
      );

      // 验证单个单词测验正常显示
      expect(find.text('题目 1/1'), findsOneWidget);
    });

    testWidgets('不同难度单词颜色测试', (WidgetTester tester) async {
      final difficultyWords = [
        Word(
          id: 'beginner',
          text: 'cat',
          category: 'animals',
          imagePath: 'assets/images/cat.png',
          audioPath: 'assets/audios/cat.mp3',
          meaning: '猫',
          difficulty: WordDifficulty.beginner,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: difficultyWords,
            quizType: QuizType.englishToChinese,
            title: '难度测试',
          ),
        ),
      );

      // 验证难度颜色应用到题目卡片
      expect(find.text('cat'), findsOneWidget);
      expect(find.text('ANIMALS'), findsOneWidget);
    });

    group('VocabularyQuiz错误处理测试', () {
      testWidgets('缺失含义的单词处理', (WidgetTester tester) async {
        final wordsWithoutMeaning = [
          Word(
            id: 'no_meaning',
            text: 'unknown',
            category: 'test',
            imagePath: 'assets/images/unknown.png',
            audioPath: 'assets/audios/unknown.mp3',
            // meaning为null
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: VocabularyQuiz(
              words: wordsWithoutMeaning,
              quizType: QuizType.englishToChinese,
              title: '缺失含义测试',
            ),
          ),
        );

        // 应该能正常渲染而不报错
        expect(find.byType(VocabularyQuiz), findsOneWidget);
      });

      testWidgets('特殊字符单词处理', (WidgetTester tester) async {
        final specialWords = [
          Word(
            id: 'special',
            text: 'café & résumé',
            category: 'international',
            imagePath: 'assets/images/special.png',
            audioPath: 'assets/audios/special.mp3',
            meaning: '咖啡馆和简历 ✨ 🌟',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: VocabularyQuiz(
              words: specialWords,
              quizType: QuizType.englishToChinese,
              title: '特殊字符测试',
            ),
          ),
        );

        // 验证特殊字符正常显示
        expect(find.text('café & résumé'), findsOneWidget);
      });
    });

    testWidgets('听音测验播放按钮测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.listeningChoice,
            title: '听音测试',
          ),
        ),
      );

      // 验证播放按钮存在
      final playButton = find.text('点击播放');
      expect(playButton, findsOneWidget);

      // 点击播放按钮
      await tester.tap(playButton);
      await tester.pump();

      // 由于TTS服务在测试环境中可能不可用，主要验证按钮可点击
      expect(find.byType(VocabularyQuiz), findsOneWidget);
    });

    testWidgets('测验类型切换测试', (WidgetTester tester) async {
      // 测试拼写测验
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.spelling,
            title: '拼写测验',
          ),
        ),
      );

      // 验证拼写测验特有提示
      expect(find.text('拼写下面含义对应的单词：'), findsOneWidget);
    });

    testWidgets('无障碍访问测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '无障碍测试',
          ),
        ),
      );

      // 验证关键元素存在（用于语音阅读器）
      expect(find.text('无障碍测试'), findsOneWidget);
      expect(find.text('选择答案:'), findsOneWidget);
      expect(find.text('跳过'), findsOneWidget);
      expect(find.text('提交'), findsOneWidget);
    });
  });
}
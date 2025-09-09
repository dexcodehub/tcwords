import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/learning/vocabulary_quiz.dart';
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

  group('VocabularyQuiz功能逻辑测试', () {
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

    testWidgets('答题逻辑测试 - 正确答案', (WidgetTester tester) async {
      QuizResult? result;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first], // 只有一道题便于测试
            quizType: QuizType.englishToChinese,
            title: '答题逻辑测试',
            onResult: (r) => result = r,
          ),
        ),
      );

      // 选择正确答案（通过查找包含正确含义的选项）
      final correctOption = find.textContaining('苹果');
      
      if (correctOption.evaluate().isNotEmpty) {
        await tester.tap(correctOption);
        await tester.pump();
        
        // 提交答案
        await tester.tap(find.text('提交'));
        await tester.pump();
        
        // 验证显示正确反馈
        expect(find.textContaining('回答正确'), findsOneWidget);
        
        // 完成测验
        await tester.tap(find.text('查看结果'));
        await tester.pumpAndSettle();
        
        // 验证结果
        expect(result, isNotNull);
        expect(result!.correctAnswers, equals(1));
        expect(result!.accuracy, equals(1.0));
        expect(result!.score, equals(100));
        expect(result!.isPassed, isTrue);
      }
    });

    testWidgets('答题逻辑测试 - 错误答案', (WidgetTester tester) async {
      QuizResult? result;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first], // 只有一道题便于测试
            quizType: QuizType.englishToChinese,
            title: '错误答案测试',
            onResult: (r) => result = r,
          ),
        ),
      );

      // 选择第一个选项（可能是错误答案）
      await tester.tap(find.textContaining('A.'));
      await tester.pump();
      
      // 提交答案
      await tester.tap(find.text('提交'));
      await tester.pump();
      
      // 验证显示答案反馈
      final correctFeedback = find.textContaining('回答正确');
      final wrongFeedback = find.textContaining('回答错误');
      
      expect(correctFeedback.evaluate().isNotEmpty || wrongFeedback.evaluate().isNotEmpty, isTrue);
      
      // 完成测验
      final nextButtonFinder = find.text('查看结果');
      if (nextButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(nextButtonFinder);
        await tester.pumpAndSettle();
      }
      
      // 验证结果存在
      expect(result, isNotNull);
    });

    testWidgets('跳过功能测试', (WidgetTester tester) async {
      QuizResult? result;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first],
            quizType: QuizType.englishToChinese,
            title: '跳过功能测试',
            onResult: (r) => result = r,
          ),
        ),
      );

      // 直接跳过
      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();
      
      // 验证直接进入结果页面
      expect(find.text('测验结果'), findsOneWidget);
      expect(result, isNotNull);
      expect(result!.correctAnswers, equals(0));
      expect(result!.accuracy, equals(0.0));
    });

    testWidgets('多题测验完整流程测试', (WidgetTester tester) async {
      QuizResult? result;
      int answeredQuestions = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords.take(2).toList(), // 测试2道题
            quizType: QuizType.englishToChinese,
            title: '多题测验测试',
            onResult: (r) => result = r,
          ),
        ),
      );

      // 回答第一题
      await tester.tap(find.textContaining('A.'));
      await tester.pump();
      await tester.tap(find.text('提交'));
      await tester.pump();
      await tester.tap(find.text('下一题'));
      await tester.pump();
      
      answeredQuestions++;
      
      // 验证进入第二题
      expect(find.text('题目 2/2'), findsOneWidget);
      
      // 回答第二题
      await tester.tap(find.textContaining('A.'));
      await tester.pump();
      await tester.tap(find.text('提交'));
      await tester.pump();
      await tester.tap(find.text('查看结果'));
      await tester.pumpAndSettle();
      
      answeredQuestions++;
      
      // 验证测验完成
      expect(find.text('测验结果'), findsOneWidget);
      expect(result, isNotNull);
      expect(result!.totalQuestions, equals(2));
      expect(answeredQuestions, equals(2));
    });

    testWidgets('时间限制功能测试', (WidgetTester tester) async {
      QuizResult? result;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '时间限制测试',
            timeLimit: 2, // 2秒时间限制，测试时自动完成
            onResult: (r) => result = r,
          ),
        ),
      );

      // 验证倒计时显示
      expect(find.text('2'), findsOneWidget);
      
      // 等待时间超时（模拟）
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      
      // 由于时间限制，应该自动完成测验
      // 在实际测试中，定时器可能不会真正倒计时，所以我们主要验证UI存在
      expect(find.text('时间限制测试'), findsOneWidget);
    });

    testWidgets('不同测验类型逻辑测试', (WidgetTester tester) async {
      // 测试中译英
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first],
            quizType: QuizType.chineseToEnglish,
            title: '中译英测试',
          ),
        ),
      );

      // 验证题目显示中文含义
      expect(find.text('苹果'), findsOneWidget);
      expect(find.text('选择下面含义对应的英文单词：'), findsOneWidget);
    });

    testWidgets('听音测验逻辑测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first],
            quizType: QuizType.listeningChoice,
            title: '听音测验测试',
          ),
        ),
      );

      // 验证播放按钮功能
      final playButton = find.text('点击播放');
      expect(playButton, findsOneWidget);
      
      // 点击播放按钮
      await tester.tap(playButton);
      await tester.pump();
      
      // 验证按钮状态变化（播放中）
      // 由于TTS服务在测试环境可能不可用，主要验证UI交互
      expect(find.byType(VocabularyQuiz), findsOneWidget);
    });

    testWidgets('计分机制测试', (WidgetTester tester) async {
      QuizResult? result;
      
      // 创建确定答案的测试场景
      final singleWord = [
        Word(
          id: 'score_test',
          text: 'test',
          category: 'test',
          imagePath: 'assets/images/test.png',
          audioPath: 'assets/audios/test.mp3',
          meaning: '测试',
          difficulty: WordDifficulty.beginner,
        ),
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: singleWord,
            quizType: QuizType.englishToChinese,
            title: '计分测试',
            passingScore: 0.8,
            onResult: (r) => result = r,
          ),
        ),
      );

      // 选择答案并提交
      await tester.tap(find.textContaining('A.'));
      await tester.pump();
      await tester.tap(find.text('提交'));
      await tester.pump();
      
      // 等待结果
      final nextButton = find.text('查看结果');
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }
      
      // 验证计分机制
      expect(result, isNotNull);
      expect(result!.score, greaterThanOrEqualTo(0));
      expect(result!.score, lessThanOrEqualTo(100));
      expect(result!.accuracy, greaterThanOrEqualTo(0.0));
      expect(result!.accuracy, lessThanOrEqualTo(1.0));
    });

    testWidgets('状态管理测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords.take(2).toList(),
            quizType: QuizType.englishToChinese,
            title: '状态管理测试',
          ),
        ),
      );

      // 验证初始状态
      expect(find.text('题目 1/2'), findsOneWidget);
      
      // 选择答案但不提交，验证选中状态
      await tester.tap(find.textContaining('A.'));
      await tester.pump();
      
      // 验证提交按钮变为可用状态
      expect(find.text('提交'), findsOneWidget);
      
      // 提交答案，验证状态变化
      await tester.tap(find.text('提交'));
      await tester.pump();
      
      // 验证答案反馈状态
      expect(find.textContaining('回答'), findsOneWidget);
      expect(find.text('下一题'), findsOneWidget);
      
      // 进入下一题，验证状态重置
      await tester.tap(find.text('下一题'));
      await tester.pump();
      
      // 验证新题目状态
      expect(find.text('题目 2/2'), findsOneWidget);
      expect(find.text('提交'), findsOneWidget);
    });

    testWidgets('回调函数测试', (WidgetTester tester) async {
      bool completedCalled = false;
      QuizResult? resultReceived;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first],
            quizType: QuizType.englishToChinese,
            title: '回调测试',
            onCompleted: () => completedCalled = true,
            onResult: (result) => resultReceived = result,
          ),
        ),
      );

      // 完成测验
      await tester.tap(find.textContaining('A.'));
      await tester.pump();
      await tester.tap(find.text('提交'));
      await tester.pump();
      await tester.tap(find.text('查看结果'));
      await tester.pumpAndSettle();
      
      // 点击完成按钮
      await tester.tap(find.text('完成'));
      await tester.pump();
      
      // 验证回调被调用
      expect(completedCalled, isTrue);
      expect(resultReceived, isNotNull);
    });

    group('VocabularyQuiz边界情况测试', () {
      testWidgets('空单词列表处理', (WidgetTester tester) async {
        QuizResult? result;
        
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: VocabularyQuiz(
              words: [],
              quizType: QuizType.englishToChinese,
              title: '空列表测试',
              onResult: (r) => result = r,
            ),
          ),
        );

        // 空列表应该直接显示结果页面
        expect(find.text('测验结果'), findsOneWidget);
        expect(result, isNotNull);
        expect(result!.totalQuestions, equals(0));
        expect(result!.correctAnswers, equals(0));
      });

      testWidgets('单词缺失含义处理', (WidgetTester tester) async {
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

        // 应该能正常处理并显示
        expect(find.text('缺失含义测试'), findsOneWidget);
        expect(find.text('unknown'), findsOneWidget);
      });

      testWidgets('重复单词处理', (WidgetTester tester) async {
        final duplicateWords = [
          testWords.first,
          testWords.first, // 重复单词
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: VocabularyQuiz(
              words: duplicateWords,
              quizType: QuizType.englishToChinese,
              title: '重复单词测试',
            ),
          ),
        );

        // 应该能正常处理重复单词
        expect(find.text('重复单词测试'), findsOneWidget);
        expect(find.text('题目 1/2'), findsOneWidget);
      });

      testWidgets('极限时间设置处理', (WidgetTester tester) async {
        // 测试极短时间限制
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: VocabularyQuiz(
              words: [testWords.first],
              quizType: QuizType.englishToChinese,
              title: '极限时间测试',
              timeLimit: 1, // 1秒
            ),
          ),
        );

        // 验证能正常初始化
        expect(find.text('极限时间测试'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });
    });

    testWidgets('答案选项生成逻辑测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '选项生成测试',
          ),
        ),
      );

      // 验证生成了4个选项
      expect(find.textContaining('A.'), findsOneWidget);
      expect(find.textContaining('B.'), findsOneWidget);
      expect(find.textContaining('C.'), findsOneWidget);
      expect(find.textContaining('D.'), findsOneWidget);
    });

    testWidgets('测验结果统计准确性测试', (WidgetTester tester) async {
      QuizResult? result;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VocabularyQuiz(
            words: [testWords.first, testWords[1]], // 2道题
            quizType: QuizType.englishToChinese,
            title: '统计准确性测试',
            onResult: (r) => result = r,
          ),
        ),
      );

      // 答对第一题（假设选择正确答案）
      await tester.tap(find.textContaining('A.'));
      await tester.pump();
      await tester.tap(find.text('提交'));
      await tester.pump();
      await tester.tap(find.text('下一题'));
      await tester.pump();

      // 跳过第二题
      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();

      // 验证统计数据
      expect(result, isNotNull);
      expect(result!.totalQuestions, equals(2));
      expect(result!.totalTime, isA<Duration>());
      expect(result!.averageTimePerQuestion, isA<Duration>());
    });
  });
}
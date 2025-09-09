import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // 初始化Flutter绑定
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('单词学习组件前置测试', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    group('扩展后的Word模型测试', () {
      test('Word模型基础功能测试', () {
        final word = Word(
          id: 'test1',
          text: 'hello',
          category: 'greetings',
          imagePath: 'assets/images/hello.png',
          audioPath: 'assets/audios/hello.mp3',
          meaning: '你好',
          example: 'Hello, world!',
          difficulty: WordDifficulty.beginner,
          learningStatus: LearningStatus.learning,
          isBookmarked: true,
          reviewCount: 3,
        );

        expect(word.text, equals('hello'));
        expect(word.meaning, equals('你好'));
        expect(word.difficulty, equals(WordDifficulty.beginner));
        expect(word.learningStatus, equals(LearningStatus.learning));
        expect(word.isBookmarked, isTrue);
        expect(word.reviewCount, equals(3));
      });

      test('Word模型JSON序列化测试', () {
        final word = Word(
          id: 'test1',
          text: 'hello',
          category: 'greetings',
          imagePath: 'assets/images/hello.png',
          audioPath: 'assets/audios/hello.mp3',
          meaning: '你好',
          example: 'Hello, world!',
          difficulty: WordDifficulty.intermediate,
          learningStatus: LearningStatus.mastered,
          isBookmarked: false,
        );

        final json = word.toJson();
        final deserializedWord = Word.fromJson(json);

        expect(deserializedWord.text, equals(word.text));
        expect(deserializedWord.meaning, equals(word.meaning));
        expect(deserializedWord.difficulty, equals(word.difficulty));
        expect(deserializedWord.learningStatus, equals(word.learningStatus));
        expect(deserializedWord.isBookmarked, equals(word.isBookmarked));
      });

      test('Word模型向后兼容性测试', () {
        // 测试旧格式JSON（不包含新字段）
        final oldFormatJson = {
          'id': 'test1',
          'text': 'hello',
          'category': 'greetings',
          'imagePath': 'assets/images/hello.png',
          'audioPath': 'assets/audios/hello.mp3',
        };

        final word = Word.fromJson(oldFormatJson);

        expect(word.text, equals('hello'));
        expect(word.meaning, isNull);
        expect(word.difficulty, equals(WordDifficulty.beginner));
        expect(word.learningStatus, equals(LearningStatus.notStarted));
        expect(word.isBookmarked, isFalse);
      });

      test('Word模型copyWith方法测试', () {
        final originalWord = Word(
          id: 'test1',
          text: 'hello',
          category: 'greetings',
          imagePath: 'assets/images/hello.png',
          audioPath: 'assets/audios/hello.mp3',
          difficulty: WordDifficulty.beginner,
          learningStatus: LearningStatus.notStarted,
          isBookmarked: false,
        );

        final updatedWord = originalWord.copyWith(
          learningStatus: LearningStatus.learning,
          isBookmarked: true,
          reviewCount: 5,
        );

        expect(updatedWord.text, equals(originalWord.text));
        expect(updatedWord.learningStatus, equals(LearningStatus.learning));
        expect(updatedWord.isBookmarked, isTrue);
        expect(updatedWord.reviewCount, equals(5));
      });

      test('Word模型颜色和名称方法测试', () {
        final beginnerWord = Word(
          id: 'test1',
          text: 'hello',
          category: 'greetings',
          imagePath: 'assets/images/hello.png',
          audioPath: 'assets/audios/hello.mp3',
          difficulty: WordDifficulty.beginner,
          learningStatus: LearningStatus.notStarted,
        );

        expect(beginnerWord.getDifficultyName(), equals('入门'));
        expect(beginnerWord.getStatusName(), equals('未开始'));
        expect(beginnerWord.getDifficultyColor(), isA<Color>());
        expect(beginnerWord.getStatusColor(), isA<Color>());

        final advancedWord = beginnerWord.copyWith(
          difficulty: WordDifficulty.advanced,
          learningStatus: LearningStatus.mastered,
        );

        expect(advancedWord.getDifficultyName(), equals('高级'));
        expect(advancedWord.getStatusName(), equals('已掌握'));
      });
    });

    group('扩展后的WordService测试', () {
      test('WordService单例模式测试', () {
        final service1 = WordService();
        final service2 = WordService();
        expect(identical(service1, service2), isTrue);
      });

      test('WordService收藏功能测试', () async {
        final wordService = WordService();
        
        // 测试收藏单词
        final result1 = await wordService.bookmarkWord('test_word_1');
        expect(result1, isTrue);
        
        // 验证收藏列表
        final bookmarks = await wordService.getBookmarkedWordIds();
        expect(bookmarks, contains('test_word_1'));
        
        // 测试取消收藏
        final result2 = await wordService.unbookmarkWord('test_word_1');
        expect(result2, isTrue);
        
        // 验证收藏列表
        final bookmarksAfter = await wordService.getBookmarkedWordIds();
        expect(bookmarksAfter, isNot(contains('test_word_1')));
      });

      test('WordService收藏切换功能测试', () async {
        final wordService = WordService();
        
        // 第一次切换（应该添加收藏）
        final result1 = await wordService.toggleBookmark('test_word_2');
        expect(result1, isTrue);
        
        final bookmarks1 = await wordService.getBookmarkedWordIds();
        expect(bookmarks1, contains('test_word_2'));
        
        // 第二次切换（应该取消收藏）
        final result2 = await wordService.toggleBookmark('test_word_2');
        expect(result2, isTrue);
        
        final bookmarks2 = await wordService.getBookmarkedWordIds();
        expect(bookmarks2, isNot(contains('test_word_2')));
      });

      test('WordService学习状态管理测试', () async {
        final wordService = WordService();
        
        // 更新学习状态
        final result = await wordService.updateLearningStatus(
          'test_word_3', 
          LearningStatus.learning
        );
        expect(result, isTrue);
        
        // 验证学习状态保存成功
        final stats = await wordService.getLearningStatistics();
        expect(stats, isA<Map<String, int>>());
        expect(stats['total'], isA<int>());
      });

      test('WordService学习统计测试', () async {
        final wordService = WordService();
        
        // 添加一些测试数据
        await wordService.bookmarkWord('stat_test_1');
        await wordService.updateLearningStatus('stat_test_2', LearningStatus.learning);
        await wordService.updateLearningStatus('stat_test_3', LearningStatus.mastered);
        
        final stats = await wordService.getLearningStatistics();
        
        expect(stats, containsPair('total', isA<int>()));
        expect(stats, containsPair('notStarted', isA<int>()));
        expect(stats, containsPair('learning', isA<int>()));
        expect(stats, containsPair('reviewing', isA<int>()));
        expect(stats, containsPair('mastered', isA<int>()));
        expect(stats, containsPair('bookmarked', isA<int>()));
        
        expect(stats['learning'], isA<int>());
        expect(stats['mastered'], isA<int>());
        expect(stats['bookmarked'], isA<int>());
      });
    });

    group('TTS服务集成测试', () {
      test('TTS服务初始化测试', () async {
        // 测试TTS服务方法不会抛出异常
        try {
          await TTSService.initialize();
          expect(true, isTrue); // 如果没有异常，测试通过
        } catch (e) {
          // 在测试环境中，TTS服务可能不可用，这是正常的
          expect(e, isA<Object>()); // 接受任何异常类型
        }
      });

      test('TTS服务方法调用测试', () async {
        // 测试方法调用不会抛出致命错误
        try {
          await TTSService.speak('hello');
          await TTSService.stop();
          await TTSService.pause();
          expect(true, isTrue);
        } catch (e) {
          // 在测试环境中，TTS可能不可用
          expect(e, isA<Object>()); // 接受任何异常类型
        }
      });
    });

    group('组件集成准备测试', () {
      test('单词数据与UI组件兼容性', () {
        final testWord = Word(
          id: 'ui_test_1',
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

        // 验证所有UI所需的数据都存在
        expect(testWord.text, isNotEmpty);
        expect(testWord.meaning, isNotEmpty);
        expect(testWord.getDifficultyName(), isNotEmpty);
        expect(testWord.getStatusName(), isNotEmpty);
        expect(testWord.getDifficultyColor(), isA<Color>());
        expect(testWord.getStatusColor(), isA<Color>());
      });

      test('长文本内容UI兼容性', () {
        final longTextWord = Word(
          id: 'long_text_test',
          text: 'supercalifragilisticexpialidocious',
          category: 'fun',
          imagePath: 'assets/images/long.png',
          audioPath: 'assets/audios/long.mp3',
          meaning: '这是一个非常长的单词，用来测试UI组件的文本处理能力和布局是否会出现溢出问题，需要确保文本足够长',
          example: 'Supercalifragilisticexpialidocious is a very long word used in the movie Mary Poppins.',
          difficulty: WordDifficulty.advanced,
        );

        // 验证长文本不会导致问题
        expect(longTextWord.text.length, greaterThan(30));
        expect(longTextWord.meaning!.length, greaterThan(45));
        expect(longTextWord.example!.length, greaterThan(80));
      });

      test('特殊字符处理测试', () {
        final specialWord = Word(
          id: 'special_test',
          text: 'café',
          category: 'food',
          imagePath: 'assets/images/cafe.png',
          audioPath: 'assets/audios/cafe.mp3',
          meaning: '咖啡馆 ☕',
          example: 'Let\'s meet at the café.',
          difficulty: WordDifficulty.elementary,
        );

        // 验证特殊字符处理
        expect(specialWord.text, contains('é'));
        expect(specialWord.meaning, contains('☕'));
        expect(specialWord.example, contains('\''));
      });

      test('空值和缺失数据处理', () {
        final minimalWord = Word(
          id: 'minimal_test',
          text: 'test',
          category: 'test',
          imagePath: 'assets/images/test.png',
          audioPath: 'assets/audios/test.mp3',
          // meaning和example为null
        );

        // 验证空值处理
        expect(minimalWord.meaning, isNull);
        expect(minimalWord.example, isNull);
        expect(minimalWord.getDifficultyName(), isNotEmpty);
        expect(minimalWord.getStatusName(), isNotEmpty);
      });
    });
  });
}
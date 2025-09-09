// 测试各个组件的独立功能
import 'package:flutter/material.dart';
import 'package:tcword/src/widgets/learning/word_card.dart';
import 'package:tcword/src/widgets/learning/vocabulary_quiz.dart';
import 'package:tcword/src/widgets/learning/word_bookmark.dart';
import 'package:tcword/src/widgets/learning/word_search_bar.dart';
import 'package:tcword/src/views/word_matching_game.dart';
import 'package:tcword/src/views/puzzle_game.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/models/learning/quiz_models.dart';
import 'package:tcword/src/models/course_model.dart';

void main() {
  runApp(const ComponentTestApp());
}

class ComponentTestApp extends StatelessWidget {
  const ComponentTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Component Test',
      home: const ComponentTestHomePage(),
    );
  }
}

class ComponentTestHomePage extends StatelessWidget {
  const ComponentTestHomePage({super.key});

  // 创建测试用的单词数据
  static final List<Word> testWords = [
    Word(
      id: '1',
      text: 'hello',
      meaning: '你好',
      audioPath: 'audio/hello.mp3',
      imagePath: 'images/hello.png',
      difficulty: WordDifficulty.beginner,
      category: 'greetings',
      learningStatus: LearningStatus.notStarted,
    ),
    Word(
      id: '2',
      text: 'world',
      meaning: '世界',
      audioPath: 'audio/world.mp3',
      imagePath: 'images/world.png',
      difficulty: WordDifficulty.elementary,
      category: 'nouns',
      learningStatus: LearningStatus.learning,
    ),
    Word(
      id: '3',
      text: 'flutter',
      meaning: 'Flutter框架',
      audioPath: 'audio/flutter.mp3',
      imagePath: 'images/flutter.png',
      difficulty: WordDifficulty.advanced,
      category: 'technology',
      learningStatus: LearningStatus.mastered,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('组件功能测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '点击测试各个组件：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () => _testWordCard(context),
              child: const Text('测试 WordCard 组件'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => _testVocabularyQuiz(context),
              child: const Text('测试 VocabularyQuiz 组件'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => _testWordBookmark(context),
              child: const Text('测试 WordBookmark 组件'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => _testWordSearchBar(context),
              child: const Text('测试 WordSearchBar 组件'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => _testWordMatchingGame(context),
              child: const Text('测试 WordMatchingGame'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => _testPuzzleGame(context),
              child: const Text('测试 PuzzleGame'),
            ),
          ],
        ),
      ),
    );
  }

  void _testWordCard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('WordCard 测试')),
          body: Center(
            child: WordCard(
              word: testWords.first,
              onFlip: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('单词卡片翻转成功！')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _testVocabularyQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('VocabularyQuiz 测试')),
          body: VocabularyQuiz(
            words: testWords,
            quizType: QuizType.englishToChinese,
            title: '词汇测验测试',
            onCompleted: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('测验完成！')),
              );
            },
          ),
        ),
      ),
    );
  }

  void _testWordBookmark(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('WordBookmark 测试')),
          body: const WordBookmark(),
        ),
      ),
    );
  }

  void _testWordSearchBar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('WordSearchBar 测试')),
          body: const WordSearchBar(),
        ),
      ),
    );
  }

  void _testWordMatchingGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WordMatchingGame(),
      ),
    );
  }

  void _testPuzzleGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PuzzleGame(),
      ),
    );
  }
}
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/utils/simple_icons.dart';
import 'package:tcword/src/views/word_matching_game_v2.dart';
import 'package:tcword/src/views/puzzle_game_v2.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final WordService _wordService = WordService();
  List<Word> _words = [];
  List<Word> _games = [];
  
  // 游戏类型
  static const String matchingGame = 'Matching Game';
  static const String puzzleGame = 'Puzzle Game';
  static const String categoryGame = 'Category Game';
  
  String _selectedGame = matchingGame;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await _wordService.getAllWords();
    setState(() {
      _words = words;
      _games = [
        Word(
          id: '1',
          text: matchingGame,
          category: 'games',
          imagePath: 'assets/images/matching_game.png',
          audioPath: '',
        ),
        Word(
          id: '2',
          text: puzzleGame,
          category: 'games',
          imagePath: 'assets/images/puzzle_game.png',
          audioPath: '',
        ),
        Word(
          id: '3',
          text: categoryGame,
          category: 'games',
          imagePath: 'assets/images/category_game.png',
          audioPath: '',
        ),
      ];
    });
  }

  void _selectGame(String game) {
    setState(() {
      _selectedGame = game;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 游戏选择区域
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _games.map((game) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => _selectGame(game.text),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: _selectedGame == game.text 
                            ? Colors.blue.withOpacity(0.3) 
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedGame == game.text 
                              ? Colors.blue 
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getGameIcon(game.text),
                            size: 50,
                            color: _selectedGame == game.text 
                                ? Colors.blue 
                                : Colors.grey,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            game.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedGame == game.text 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              color: _selectedGame == game.text 
                                  ? Colors.blue 
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          // 游戏内容区域
          Expanded(
            child: _buildGameContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    switch (_selectedGame) {
      case matchingGame:
        return WordMatchingGameV2();
      case puzzleGame:
        return PuzzleGameV2();
      case categoryGame:
        return _CategoryGame(words: _words);
      default:
        return const Center(
          child: Text('Select a game to play'),
        );
    }
  }

  IconData _getGameIcon(String game) {
    switch (game) {
      case matchingGame:
        return Icons.extension;
      case puzzleGame:
        return Icons.extension; // 使用现有的图标替代 Icons.puzzle
      case categoryGame:
        return Icons.category;
      default:
        return Icons.games;
    }
  }
}

// 单词分类游戏
class _CategoryGame extends StatefulWidget {
  final List<Word> words;

  const _CategoryGame({required this.words});

  @override
  State<_CategoryGame> createState() => _CategoryGameState();
}

class _CategoryGameState extends State<_CategoryGame> {
  List<Word> _gameWords = [];
  List<String> _categories = [];
  Word? _currentWord;
  int _score = 0;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _prepareGame();
  }

  void _prepareGame() {
    // 获取所有类别
    final allCategories = widget.words.map((word) => word.category).toSet().toList();
    _categories = allCategories.take(4).toList(); // 取前4个类别
    
    // 选择10个随机单词用于游戏
    final randomWords = List<Word>.from(widget.words)..shuffle();
    _gameWords = randomWords.take(10).toList();
    
    if (_gameWords.isNotEmpty) {
      _setNewQuestion();
    }
  }

  void _setNewQuestion() {
    if (_gameWords.isEmpty) return;
    
    // 选择当前问题单词
    _currentWord = _gameWords[0];
  }

  void _checkAnswer(String selectedCategory) {
    setState(() {
      _attempts++;
      
      if (selectedCategory == _currentWord?.category) {
        _score++;
        // 移除已答对的单词
        _gameWords.remove(_currentWord);
        
        // 检查是否完成所有单词
        if (_gameWords.isEmpty) {
          _showGameResult();
        } else {
          _setNewQuestion();
        }
      } else {
        // 答错时重新设置问题
        _setNewQuestion();
      }
    });
  }

  void _showGameResult() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Completed!'),
          content: Text('Your score: $_score/$_attempts'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _score = 0;
                  _attempts = 0;
                  _prepareGame();
                });
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentWord == null || _categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 显示进度
            Text(
              'Score: $_score/$_attempts',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // 显示单词图片
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildWordImage(_currentWord!),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Which category does this belong to?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 显示类别选项
            ..._categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(category),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.green, width: 2),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20), // 添加底部间距
          ],
        ),
      ),
    );
  }

  Widget _buildWordImage(Word word) {
    // 首先尝试加载实际的图片文件
    try {
      return Image.asset(
        word.imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // 如果图片文件不存在，则使用简单的矢量图标
          return SimpleIcons.getIcon(word.text);
        },
      );
    } catch (e) {
      // 如果有任何错误，回退到简单的矢量图标
      return SimpleIcons.getIcon(word.text);
    }
  }
}
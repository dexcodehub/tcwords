import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/services/audio_service.dart';
import 'package:tcword/src/utils/simple_icons.dart';

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
        return _MatchingGame(words: _words);
      case puzzleGame:
        return _PuzzleGame(words: _words);
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

// 单词配对游戏
class _MatchingGame extends StatefulWidget {
  final List<Word> words;

  const _MatchingGame({required this.words});

  @override
  State<_MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<_MatchingGame> {
  List<Word> _gameWords = [];
  List<String> _options = [];
  Word? _currentWord;
  int _score = 0;
  int _attempts = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prepareGame();
  }

  Future<void> _prepareGame() async {
    try {
      // 添加一个小延迟确保widget.words已初始化
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (widget.words.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No words available for this game';
        });
        return;
      }

      // 选择5个随机单词用于游戏（或者可用单词的数量，取较小值）
      final randomWords = List<Word>.from(widget.words)..shuffle();
      _gameWords = randomWords.take(math.min(5, randomWords.length)).toList();
      
      if (_gameWords.isNotEmpty) {
        _setNewQuestion();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Not enough words available for this game';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error preparing game: $e';
      });
    }
  }

  void _setNewQuestion() {
    try {
      if (_gameWords.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No words available for this game';
        });
        return;
      }
      
      // 选择当前问题单词
      _currentWord = _gameWords[0];
      
      // 创建选项（1个正确答案 + 3个错误答案）
      _options = [_currentWord!.text];
      
      final otherWords = List<Word>.from(widget.words)
        ..removeWhere((word) => word.text == _currentWord!.text)
        ..shuffle();
      
      // 添加最多3个错误答案
      for (int i = 0; i < math.min(3, otherWords.length); i++) {
        _options.add(otherWords[i].text);
      }
      
      // 打乱选项顺序
      _options.shuffle();
      
      // 更新状态
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error setting question: $e';
      });
    }
  }

  void _checkAnswer(String selectedOption) {
    setState(() {
      _attempts++;
      
      if (selectedOption == _currentWord?.text) {
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

  @override
  Widget build(BuildContext context) {
    // 显示加载状态
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading game...'),
          ],
        ),
      );
    }
    
    // 显示错误信息
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _prepareGame,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    // 确保_currentWord不为null
    if (_currentWord == null) {
      return const Center(
        child: Text('Error: No current word selected'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 显示进度
            Text(
              'Score: $_score/$_attempts',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // 显示图片
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
            // 显示选项
            ..._options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  child: Text(
                    option,
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
}

// 单词拼图游戏
class _PuzzleGame extends StatefulWidget {
  final List<Word> words;

  const _PuzzleGame({required this.words});

  @override
  State<_PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<_PuzzleGame> {
  Word? _currentWord;
  List<String> _letters = [];
  List<String?> _userLetters = [];
  int _score = 0;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _prepareGame();
  }

  void _prepareGame() {
    // 选择一个随机单词用于游戏
    if (widget.words.isNotEmpty) {
      final randomWords = List<Word>.from(widget.words)..shuffle();
      _currentWord = randomWords.first;
      _setupPuzzle();
    }
  }

  void _setupPuzzle() {
    if (_currentWord == null) return;
    
    // 创建字母列表
    _letters = _currentWord!.text.split('');
    _userLetters = List<String?>.filled(_letters.length, null);
    
    // 打乱字母顺序
    _letters.shuffle();
  }

  void _selectLetter(int index) {
    // 找到第一个空位
    final emptyIndex = _userLetters.indexWhere((element) => element == null);
    if (emptyIndex != -1) {
      setState(() {
        _userLetters[emptyIndex] = _letters[index];
      });
      
      // 检查是否填满
      if (!_userLetters.contains(null)) {
        _checkAnswer();
      }
    }
  }

  void _clearLetter(int index) {
    setState(() {
      _userLetters[index] = null;
    });
  }

  void _checkAnswer() {
    setState(() {
      _attempts++;
      
      final userAnswer = _userLetters.join('');
      if (userAnswer == _currentWord?.text) {
        _score++;
        _showResult(true);
      } else {
        _showResult(false);
      }
    });
  }

  void _showResult(bool isCorrect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Correct!' : 'Try Again!'),
          content: Text(
            isCorrect 
                ? 'Great job! The word is ${_currentWord?.text}'
                : 'The word was ${_currentWord?.text}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _prepareGame();
              },
              child: const Text('Next Word'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    if (_currentWord == null) {
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
              height: 150,
              width: 150,
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
            // 显示用户选择的字母
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_userLetters.length, (index) {
                return Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      _userLetters[index] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            // 显示可选字母
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_letters.length, (index) {
                return ElevatedButton(
                  onPressed: () => _selectLetter(index),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _letters[index],
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            // 清除按钮
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userLetters = List<String?>.filled(_userLetters.length, null);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20), // 添加底部间距
          ],
        ),
      ),
    );
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
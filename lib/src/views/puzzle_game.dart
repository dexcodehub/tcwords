import 'package:flutter/material.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/services/achievement_service.dart';
import 'package:tcword/src/utils/simple_icons.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  final WordService _wordService = WordService();
  List<Word> _words = [];
  Word? _currentWord;
  List<String> _letters = [];
  List<String?> _userLetters = [];
  int _score = 0;
  int _attempts = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    try {
      final words = await _wordService.getAllWords();
      
      if (words.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No words available for this game';
        });
        return;
      }

      setState(() {
        _words = words;
        _isLoading = false;
      });
      
      _prepareQuestion();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading words: $e';
      });
    }
  }

  void _prepareQuestion() {
    if (_words.isEmpty) {
      setState(() {
        _errorMessage = 'No words available for this game';
      });
      return;
    }

    // 随机选择一个单词
    final shuffledWords = List<Word>.from(_words)..shuffle();
    _currentWord = shuffledWords.first;
    
    // 创建字母列表
    _letters = _currentWord!.text.split('').toList();
    _userLetters = List<String?>.filled(_letters.length, null);
    
    // 打乱字母顺序
    _letters.shuffle();
    
    setState(() {
      _showResult = false;
      _isCorrect = false;
    });
  }

  void _selectLetter(int index) {
    if (_showResult) return;
    
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
    if (_showResult) return;
    
    setState(() {
      _userLetters[index] = null;
    });
  }

  void _checkAnswer() {
    final userAnswer = _userLetters.join('');
    final isCorrect = userAnswer == _currentWord?.text;
    
    setState(() {
      _attempts++;
      _showResult = true;
      _isCorrect = isCorrect;
      
      if (isCorrect) {
        _score++;
        
        // 触发成就事件
        AchievementServiceSingleton.instance.processEvent(
          AchievementEvent(type: AchievementEventType.wordLearned),
        );
        
        // 检查是否达到完美得分
        if (_score > 0 && _attempts == _score) {
          AchievementServiceSingleton.instance.processEvent(
            AchievementEvent(type: AchievementEventType.perfectScore),
          );
        }
      }
    });

    // 延迟一段时间后进入下一题
    Future.delayed(const Duration(seconds: 1), () {
      _prepareQuestion();
    });
  }

  void _clearAll() {
    if (_showResult) return;
    
    setState(() {
      _userLetters = List<String?>.filled(_userLetters.length, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 单词拼图 🧩', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading game...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
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
                        onPressed: _loadWords,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _words.isEmpty
                  ? const Center(
                      child: Text('No words available'),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF1F8E9), Color(0xFFDCEDC8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            // 分数显示
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildScoreCard(
                                  icon: Icons.star,
                                  label: '得分',
                                  value: '$_score',
                                  color: const Color(0xFF4CAF50),
                                ),
                                _buildScoreCard(
                                  icon: Icons.extension,
                                  label: '拼图',
                                  value: '$_attempts',
                                  color: const Color(0xFFFF9800),
                                ),
                                _buildScoreCard(
                                  icon: Icons.emoji_events,
                                  label: '关卡',
                                  value: '${(_score ~/ 5) + 1}',
                                  color: const Color(0xFFE91E63),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            
                            // 问题单词图片
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.4),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: _buildWordImage(_currentWord!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // 用户拼写的单词
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: const Color(0xFF42A5F5), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_userLetters.length, (index) {
                                  return GestureDetector(
                                    onTap: () => _clearLetter(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 60,
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _userLetters[index] != null
                                              ? [const Color(0xFF42A5F5), const Color(0xFF1E88E5)]
                                              : [Colors.white, Colors.grey[100]!],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: _userLetters[index] != null
                                              ? const Color(0xFF1976D2)
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_userLetters[index] != null ? Colors.blue : Colors.grey).withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          _userLetters[index] ?? '',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: _userLetters[index] != null ? Colors.white : Colors.grey[600],
                                          ),
                                       ),
                                     ),
                                   ),
                                 );
                               }),
                             ),
                            ),
                            const SizedBox(height: 20),
                            
                            // 清除按钮
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: _clearAll,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.clear_all,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '清空全部',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // 可选字母
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: List.generate(_letters.length, (index) {
                                final colors = [
                                  const Color(0xFF9C27B0),
                                  const Color(0xFF673AB7),
                                  const Color(0xFF3F51B5),
                                  const Color(0xFF2196F3),
                                  const Color(0xFF00BCD4),
                                  const Color(0xFF009688),
                                ];
                                final buttonColor = colors[index % colors.length];
                                
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [buttonColor, buttonColor.withOpacity(0.8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: buttonColor.withOpacity(0.4),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => _selectLetter(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Text(
                                            _letters[index].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            
                            // 结果反馈
                            if (_showResult) ...[
                              const SizedBox(height: 20),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: Container(
                                  key: ValueKey(_isCorrect),
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _isCorrect 
                                          ? [Colors.green[300]!, Colors.green[100]!]
                                          : [Colors.red[300]!, Colors.red[100]!],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isCorrect ? Colors.green : Colors.red).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _isCorrect ? Icons.star : Icons.refresh,
                                          color: _isCorrect ? Colors.amber : Colors.orange,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _isCorrect ? '太棒了！🎉' : '再试一次！💪',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.3),
                                              offset: const Offset(1, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20), // 添加底部间距
                          ],
                        ),
                      ),
                    ),
                  ),
    );
  }

  Widget _buildScoreCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          return SimpleIcons.getIcon(word.text, size: 80);
        },
      );
    } catch (e) {
      // 如果有任何错误，回退到简单的矢量图标
      return SimpleIcons.getIcon(word.text, size: 80);
    }
  }
}
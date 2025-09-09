import 'package:flutter/material.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/services/achievement_service.dart';
import 'package:tcword/src/utils/simple_icons.dart';

class WordMatchingGame extends StatefulWidget {
  const WordMatchingGame({super.key});

  @override
  State<WordMatchingGame> createState() => _WordMatchingGameState();
}

class _WordMatchingGameState extends State<WordMatchingGame> {
  final WordService _wordService = WordService();
  List<Word> _words = [];
  List<Word> _questionWords = [];
  List<Word> _optionWords = [];
  Word? _currentWord;
  int _score = 0;
  int _attempts = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCorrect = false;
  bool _showResult = false;

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
    if (_words.length < 4) {
      setState(() {
        _errorMessage = 'Not enough words available for this game';
      });
      return;
    }

    // 随机选择4个不同的单词
    final shuffledWords = List<Word>.from(_words)..shuffle();
    _questionWords = shuffledWords.take(4).toList();
    
    // 选择当前问题单词
    _currentWord = _questionWords[0];
    
    // 创建选项（打乱顺序）
    _optionWords = List<Word>.from(_questionWords)..shuffle();
    
    setState(() {
      _showResult = false;
      _isCorrect = false;
    });
  }

  void _checkAnswer(Word selectedWord) {
    setState(() {
      _attempts++;
      _showResult = true;
      
      if (selectedWord.id == _currentWord?.id) {
        _isCorrect = true;
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
      } else {
        _isCorrect = false;
      }
    });

    // 延迟一段时间后进入下一题
    Future.delayed(const Duration(seconds: 1), () {
      _prepareQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 单词配对游戏 🎯', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
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
                          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
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
                                    icon: Icons.favorite,
                                    label: '尝试',
                                    value: '$_attempts',
                                    color: const Color(0xFFE91E63),
                                  ),
                                  _buildScoreCard(
                                    icon: Icons.emoji_events,
                                    label: '关卡',
                                    value: '${(_score ~/ 10) + 1}',
                                    color: const Color(0xFFFF9800),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              
                              // 问题单词图片
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: RotationTransition(
                                      turns: Tween(begin: 0.1, end: 0.0).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  key: ValueKey(_currentWord?.id),
                                  height: 220,
                                  width: 220,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.4),
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
                              ),
                            const SizedBox(height: 30),
                            
                            // 匹配单词选项
                               ..._optionWords.asMap().entries.map((entry) {
                                 final index = entry.key;
                                 final word = entry.value;
                                 final colors = [
                                   const Color(0xFF4CAF50),
                                   const Color(0xFF2196F3),
                                   const Color(0xFFFF9800),
                                   const Color(0xFFE91E63),
                                 ];
                                 final buttonColor = colors[index % colors.length];
                                 
                                 return Padding(
                                   padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                   child: AnimatedContainer(
                                     duration: const Duration(milliseconds: 300),
                                     transform: Matrix4.identity()..scale(_showResult && word.id == _currentWord?.id ? 1.1 : 1.0),
                                     child: Container(
                                       width: double.infinity,
                                       decoration: BoxDecoration(
                                         gradient: LinearGradient(
                                           colors: _showResult
                                               ? (word.id == _currentWord?.id
                                                   ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                                                   : [const Color(0xFFE57373), const Color(0xFFEF5350)])
                                               : [buttonColor, buttonColor.withOpacity(0.8)],
                                           begin: Alignment.topLeft,
                                           end: Alignment.bottomRight,
                                         ),
                                         borderRadius: BorderRadius.circular(25),
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
                                           borderRadius: BorderRadius.circular(25),
                                           onTap: _showResult ? null : () => _checkAnswer(word),
                                           child: Container(
                                             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                             child: Row(
                                               mainAxisAlignment: MainAxisAlignment.center,
                                               children: [
                                                 if (_showResult && word.id == _currentWord?.id)
                                                   const Icon(
                                                     Icons.check_circle,
                                                     color: Colors.white,
                                                     size: 28,
                                                   ),
                                                 if (_showResult && word.id != _currentWord?.id)
                                                   const Icon(
                                                     Icons.cancel,
                                                     color: Colors.white,
                                                     size: 28,
                                                   ),
                                                 if (_showResult) const SizedBox(width: 10),
                                                 Text(
                                                   word.text.toUpperCase(),
                                                   style: const TextStyle(
                                                     fontSize: 24,
                                                     fontWeight: FontWeight.bold,
                                                     color: Colors.white,
                                                     letterSpacing: 1.2,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ),
                                       ),
                                     ),
                                   ),
                                 );
                               }).toList(),
                               
                               // 结果反馈
                               if (_showResult) ...[
                                 const SizedBox(height: 20),
                                 AnimatedSwitcher(
                                   duration: const Duration(milliseconds: 300),
                                   child: Container(
                                     key: ValueKey(_isCorrect),
                                     padding: const EdgeInsets.all(16),
                                     decoration: BoxDecoration(
                                       gradient: LinearGradient(
                                         colors: _isCorrect 
                                             ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                                             : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                                         begin: Alignment.topLeft,
                                         end: Alignment.bottomRight,
                                       ),
                                       borderRadius: BorderRadius.circular(20),
                                       boxShadow: [
                                         BoxShadow(
                                           color: (_isCorrect ? Colors.green : Colors.red).withOpacity(0.3),
                                           spreadRadius: 3,
                                           blurRadius: 10,
                                           offset: const Offset(0, 5),
                                         ),
                                       ],
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(
                                           _isCorrect
                                               ? Icons.star
                                               : Icons.favorite_border,
                                           color: Colors.white,
                                           size: 30,
                                         ),
                                         const SizedBox(width: 10),
                                         Text(
                                           _isCorrect ? '太棒了！🎉' : '再试一次！💪',
                                           style: const TextStyle(
                                             color: Colors.white,
                                             fontSize: 20,
                                             fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
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
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          return SimpleIcons.getIcon(word.text, size: 100);
        },
      );
    } catch (e) {
      // 如果有任何错误，回退到简单的矢量图标
      return SimpleIcons.getIcon(word.text, size: 100);
    }
  }
}
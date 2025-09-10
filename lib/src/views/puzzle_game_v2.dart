import 'package:flutter/material.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/services/achievement_service.dart';
import 'package:tcword/src/utils/simple_icons.dart';
import 'package:tcword/src/services/game_engine_service.dart';
import 'package:tcword/src/widgets/game_base_widget.dart';

/// 现代化单词拼图游戏 - 使用新的游戏引擎技术
class PuzzleGameV2 extends GameBaseWidget {
  // 移除了 const，因为 AdaptiveDifficulty 不是 const 构造函数
  PuzzleGameV2({super.key})
      : super(
          gameTitle: '单词拼图大师',
          primaryColor: const Color(0xFF4CAF50),
          secondaryColor: const Color(0xFF66BB6A),
          difficulty: AdaptiveDifficulty(initialDifficulty: 0.5),
        );

  @override
  State<PuzzleGameV2> createState() => _PuzzleGameV2State();

  @override
  Widget buildGameContent(BuildContext context, GameBaseState state) {
    // 调用状态类中的实现
    return (state as _PuzzleGameV2State).buildGameContent(context);
  }

  @override
  Widget buildGameControls(BuildContext context, GameBaseState state) {
    // 调用状态类中的实现
    return (state as _PuzzleGameV2State).buildGameControls(context);
  }
}

class _PuzzleGameV2State extends GameBaseState<PuzzleGameV2> {
  final WordService _wordService = WordService();
  final List<AnimationController> _letterAnimations = [];
  final List<Animation<double>> _letterScales = [];
  final List<Animation<Color?>> _letterColors = [];

  List<Word> _words = [];
  Word? _currentWord;
  List<String> _letters = [];
  List<String?> _userLetters = [];
  bool _showResult = false;
  bool _isCorrect = false;
  String? _errorMessage;
  DateTime? _questionStartTime;

  late AnimationController _questionAnimation;
  late Animation<double> _questionScale;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadWords();
  }

  void _initializeAnimations() {
    _questionAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _questionScale = GameEngineService.createBounceAnimation(_questionAnimation);
  }

  @override
  void onGameInitialized() {
    _prepareQuestion();
  }

  Future<void> _loadWords() async {
    try {
      final words = await _wordService.getAllWords();
      if (words.isEmpty) {
        setState(() {
          _errorMessage = '没有可用的单词进行游戏';
        });
        return;
      }

      setState(() {
        _words = words;
      });
      
      _prepareQuestion();
    } catch (e) {
      setState(() {
        _errorMessage = '加载单词时出错: $e';
      });
    }
  }

  void _prepareQuestion() {
    if (_words.isEmpty) {
      setState(() {
        _errorMessage = '没有可用的单词进行游戏';
      });
      return;
    }

    // 根据难度生成游戏参数
    final params = widget.difficulty.generateGameParameters();
    final maxWordLength = (params['optionsCount'] as int).clamp(3, 8);

    // 过滤出合适长度的单词
    final suitableWords = _words.where((word) => word.text.length <= maxWordLength).toList();
    if (suitableWords.isEmpty) {
      setState(() {
        _errorMessage = '没有合适长度的单词进行游戏';
      });
      return;
    }

    // 随机选择一个单词
    final shuffledWords = List<Word>.from(suitableWords)..shuffle();
    _currentWord = shuffledWords.first;
    
    // 创建字母列表
    _letters = _currentWord!.text.split('').toList();
    _userLetters = List<String?>.filled(_letters.length, null);
    
    // 打乱字母顺序
    _letters.shuffle();
    
    // 初始化字母动画
    _initializeLetterAnimations();

    setState(() {
      _showResult = false;
      _isCorrect = false;
      _errorMessage = null;
      _questionStartTime = DateTime.now(); // 记录问题开始时间
    });

    // 播放问题出现动画
    _questionAnimation.reset();
    _questionAnimation.forward();
  }

  void _initializeLetterAnimations() {
    // 清理旧的动画控制器
    for (final controller in _letterAnimations) {
      controller.dispose();
    }
    _letterAnimations.clear();
    _letterScales.clear();
    _letterColors.clear();

    // 创建新的动画控制器
    for (int i = 0; i < _letters.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );

      final scale = GameEngineService.createBounceAnimation(controller);
      final color = GameEngineService.createColorTransitionAnimation(
        controller,
        _getLetterColor(i),
        _getLetterColor(i).withValues(alpha: 0.8),
      );

      _letterAnimations.add(controller);
      _letterScales.add(scale);
      _letterColors.add(color);

      // 延迟播放动画，创建波浪效果
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) controller.forward();
      });
    }
  }

  Color _getLetterColor(int index) {
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
      Color(0xFFFF9800),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
    ];
    return colors[index % colors.length];
  }

  void _selectLetter(int index) {
    onUserInteraction();
    if (_showResult) return;
    
    // 找到第一个空位
    final emptyIndex = _userLetters.indexWhere((element) => element == null);
    if (emptyIndex != -1) {
      setState(() {
        _userLetters[emptyIndex] = _letters[index];
      });
      
      // 播放字母动画
      if (index < _letterAnimations.length) {
        _letterAnimations[index].reset();
        _letterAnimations[index].forward();
      }
      
      // 检查是否填满
      if (!_userLetters.contains(null)) {
        _checkAnswer();
      }
    }
  }

  void _clearLetter(int index) {
    onUserInteraction();
    if (_showResult) return;
    
    setState(() {
      _userLetters[index] = null;
    });
    
    // 播放字母动画
    if (index < _letterAnimations.length) {
      _letterAnimations[index].reset();
      _letterAnimations[index].forward();
    }
  }

  void _checkAnswer() {
    onUserInteraction();
    incrementAttempts();

    final userAnswer = _userLetters.join('');
    final isCorrect = userAnswer == _currentWord?.text;
    final responseTime = 1.0; // 简化响应时间计算

    // 调整难度
    widget.difficulty.adjustDifficulty(isCorrect, responseTime);

    setState(() {
      _showResult = true;
      _isCorrect = isCorrect;
    });

    // 播放反馈动画
    _playFeedbackAnimation(isCorrect);

    if (isCorrect) {
      updateScore(15); // 拼图游戏分数更高
      
      // 触发成就事件
      AchievementServiceSingleton.instance.processEvent(
        AchievementEvent(type: AchievementEventType.wordLearned),
      );

      // 检查是否达到完美得分
      if (score > 0 && attempts == score) {
        AchievementServiceSingleton.instance.processEvent(
          AchievementEvent(type: AchievementEventType.perfectScore),
        );
      }

      // 检查是否升级
      if (score % 50 == 0) {
        levelUp();
      }
    }

    // 延迟进入下一题
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _prepareQuestion();
    });
  }

  void _playFeedbackAnimation(bool isCorrect) {
    // 播放字母动画
    for (int i = 0; i < _letterAnimations.length; i++) {
      _letterAnimations[i].reset();
      _letterAnimations[i].forward();
    }
  }

  void _clearAll() {
    onUserInteraction();
    if (_showResult) return;
    
    setState(() {
      _userLetters = List<String?>.filled(_userLetters.length, null);
    });
    
    // 播放所有字母动画
    for (int i = 0; i < _letterAnimations.length; i++) {
      _letterAnimations[i].reset();
      _letterAnimations[i].forward();
    }
  }

  Widget _buildWordImage(Word word) {
    return AnimatedBuilder(
      animation: _questionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _questionScale.value,
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50),
                  const Color(0xFF66BB6A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  spreadRadius: 3,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _getWordImageContent(word),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getWordImageContent(Word word) {
    try {
      return Image.asset(
        word.imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return SimpleIcons.getIcon(word.text, size: 80);
        },
      );
    } catch (e) {
      return SimpleIcons.getIcon(word.text, size: 80);
    }
  }

  Widget _buildLetterButton(int index, String letter) {
    return AnimatedBuilder(
      animation: _letterAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _letterScales[index].value,
          child: GameCard(
            backgroundColor: _letterColors[index].value ?? _getLetterColor(index),
            onTap: () => _selectLetter(index),
            child: Center(
              child: Text(
                letter.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserLetterSlot(int index) {
    final letter = _userLetters[index];
    
    return GestureDetector(
      onTap: letter != null ? () => _clearLetter(index) : null,
      child: GameCard(
        backgroundColor: letter != null 
            ? const Color(0xFF2196F3) 
            : Colors.grey.withOpacity(0.3),
        child: Center(
          child: Text(
            letter?.toUpperCase() ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    if (!_showResult) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
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
            color: (_isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.3),
            spreadRadius: 3,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCorrect ? Icons.star : Icons.favorite,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect ? '太棒了！+15分 🎉' : '继续加油！ 💪',
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

  @override
  Widget buildGameContent(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            GameButton(
              text: '重试',
              icon: Icons.refresh,
              color: const Color(0xFFFF6B6B),
              onPressed: _loadWords,
            ),
          ],
        ),
      );
    }

    if (_currentWord == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 问题单词图片
                  _buildWordImage(_currentWord!),
                  const SizedBox(height: 32),
                  
                  // 用户拼写字母槽
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(_userLetters.length, (index) {
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: _buildUserLetterSlot(index),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  
                  // 操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GameButton(
                        text: '清空',
                        icon: Icons.clear,
                        color: const Color(0xFFFF9800),
                        onPressed: _clearAll,
                      ),
                      const SizedBox(width: 16),
                      GameButton(
                        text: '提交',
                        icon: Icons.check,
                        color: const Color(0xFF4CAF50),
                        onPressed: () {
                          if (!_userLetters.contains(null)) {
                            _checkAnswer();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 可选字母
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(_letters.length, (index) {
                      // 检查该字母是否已被使用
                      final isUsed = _userLetters.contains(_letters[index]);
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: isUsed
                            ? GameCard(
                                backgroundColor: Colors.grey.withOpacity(0.3),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              )
                            : _buildLetterButton(index, _letters[index]),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 反馈信息
                  _buildFeedback(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildGameControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GameButton(
          text: '提示',
          icon: Icons.lightbulb,
          color: const Color(0xFFFF9800),
          onPressed: () {
            // 提示功能实现
          },
        ),
        GameButton(
          text: '跳过',
          icon: Icons.skip_next,
          color: const Color(0xFF2196F3),
          onPressed: _prepareQuestion,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _questionAnimation.dispose();
    for (final controller in _letterAnimations) {
      controller.dispose();
    }
    super.dispose();
  }
}